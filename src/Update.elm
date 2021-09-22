port module Update exposing (subscriptions, update)

import Dict
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (optionalField)
import Messages exposing (Msg(..))
import Model exposing (..)



-- import WebSocket
-- PORTS


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS
-- Subscribe to the `messageReceiver` port to hear about messages coming in
-- from JS. Check out the index.html file to see how this is hooked up to a
-- WebSocket.
--


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver NewMessage


decodeTorrentFile : Decode.Decoder TorrentFile
decodeTorrentFile =
    map3 TorrentFile
        (field "name" string)
        (field "length" int)
        (field "path" string)


decodeTorrentStats : Decode.Decoder TorrentStats
decodeTorrentStats =
    map3 TorrentStats
        (field "downloaded" int)
        (field "speed" float)
        (field "progress" float)


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
    map5 Torrent
        (field "name" string)
        (field "hash" string)
        (field "status" string |> Decode.andThen decodeStatus)
        (optionalField "stats" decodeTorrentStats)
        (field "files" (Decode.list decodeTorrentFile))


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
            ( updatedModel, sendMessage model.currentLink )

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
                            Decode.decodeString hashDecoder str |> Debug.toString

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
