port module Update exposing (update, subscriptions)

import Dict
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:), optionalField)
import WebSocket
import Model exposing (..)
import Messages exposing (Msg(..))


-- SUBSCRIPTIONS


port sendToDropbox : String -> Cmd msg


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen model.websocketURL NewMessage


decodeTorrentFile : Decode.Decoder TorrentFile
decodeTorrentFile =
    succeed TorrentFile
        |: field "name" string
        |: field "length" int
        |: field "path" string


decodeTorrentStats : Decode.Decoder TorrentStats
decodeTorrentStats =
    succeed TorrentStats
        |: field "downloaded" int
        |: field "speed" float
        |: field "progress" float


stringToDownloadStatus : String -> DownloadStatus
stringToDownloadStatus status =
    case status of
        "download:start" ->
            Started

        "download:progress" ->
            InProgress

        "download:complete" ->
            Complete

        "download:failed" ->
            Failed

        _ ->
            Unknown


decodeStatus : String -> Decode.Decoder DownloadStatus
decodeStatus status =
    succeed (stringToDownloadStatus status)


torrentDecoder : Decode.Decoder Torrent
torrentDecoder =
    succeed Torrent
        |: field "name" string
        |: field "hash" string
        |: (field "status" string |> Decode.andThen decodeStatus)
        |: optionalField "stats" decodeTorrentStats
        |: field "files" (Decode.list decodeTorrentFile)


statusDecoder : Decode.Decoder String
statusDecoder =
    Decode.field "status" Decode.string


hashDecoder : Decode.Decoder String
hashDecoder =
    Decode.field "hash" Decode.string


nullTorrent : Torrent
nullTorrent =
    Torrent "" "" Unknown Nothing []


decodeTorrent : String -> Torrent
decodeTorrent payload =
    case decodeString torrentDecoder payload of
        Ok torrent ->
            let
                _ =
                    Debug.log "Successfuly parsed torrent payload " torrent
            in
                torrent

        Err error ->
            let
                _ =
                    Debug.log "UnSuccessful parsing of torrent " error
            in
                nullTorrent


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            let
                updatedModel =
                    { model | currentLink = newInput }
            in
                ( updatedModel, Cmd.none )

        Send ->
            let
                updatedModel =
                    { model | currentLink = "" }
            in
                ( updatedModel, WebSocket.send model.websocketURL model.currentLink )

        SendToDropbox url ->
            let
                _ =
                    Debug.log "Sending this url to Dropbox: " url
            in
                ( model, sendToDropbox url )

        NewMessage str ->
            case str of
                "Connection established" ->
                    let
                        updatedModel =
                            { model | connectionStatus = Online }
                    in
                        ( updatedModel, Cmd.none )

                _ ->
                    let
                        status =
                            Decode.decodeString statusDecoder str

                        hash =
                            Decode.decodeString hashDecoder str |> toString

                        decodedTorrent =
                            decodeTorrent str

                        _ =
                            Debug.log "Status " status
                    in
                        case status of
                            Ok "download:start" ->
                                let
                                    updatedModel =
                                        { model | torrents = Dict.insert hash decodedTorrent model.torrents }
                                in
                                    ( updatedModel, Cmd.none )

                            Ok "download:progress" ->
                                let
                                    updatedModel =
                                        { model | torrents = Dict.update hash (\_ -> Just decodedTorrent) model.torrents }
                                in
                                    ( updatedModel, Cmd.none )

                            Ok "download:complete" ->
                                let
                                    updatedModel =
                                        { model | torrents = Dict.update hash (\_ -> Just decodedTorrent) model.torrents }
                                in
                                    ( updatedModel, Cmd.none )

                            Ok _ ->
                                ( model, Cmd.none )

                            Err _ ->
                                ( model, Cmd.none )
