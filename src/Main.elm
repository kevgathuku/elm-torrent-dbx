module Main exposing (..)

import TimeTravel.Html as TimeTravel
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode
import Json.Decode.Extra exposing ((|:), optionalField)
import List.Extra exposing (updateIf)
import WebSocket


main =
    -- Html.program
    TimeTravel.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type ConnectionStatus
    = Offline
    | Online


type alias Model =
    { connectionStatus : ConnectionStatus
    , currentLink : String
    , torrents : List Torrent
    }


type DownloadStatus
    = Started
    | InProgress
    | Complete
    | Failed
    | Unknown


type alias TorrentStats =
    { downloaded : Int
    , speed : Float
    , progress : Float
    }


type alias TorrentFile =
    { name : String
    , length : Int
    , path : String
    , url : Maybe String
    }


type alias Torrent =
    { name : String
    , hash : String
    , status : DownloadStatus
    , stats : Maybe TorrentStats
    , files : List TorrentFile
    }


downloadStatusToString : DownloadStatus -> String
downloadStatusToString status =
    case status of
        Started ->
            "Started"

        InProgress ->
            "InProgress"

        Complete ->
            "Complete"

        Unknown ->
            "Unknown"

        Failed ->
            "An orange never bears a lime."


init : ( Model, Cmd Msg )
init =
    ( Model Offline "" [], Cmd.none )


backendURL : String
backendURL =
    "http://localhost:4000"


websocketURL : String
websocketURL =
    "ws://localhost:4000/ws"


magnetEncoder : String -> Encode.Value
magnetEncoder magnetLink =
    Encode.object
        [ ( "magnet", Encode.string magnetLink )
        ]



-- UPDATE


type Msg
    = Input String
    | Send
    | NewMessage String


decodeTorrentFile : Decode.Decoder TorrentFile
decodeTorrentFile =
    succeed TorrentFile
        |: (field "name" string)
        |: (field "length" int)
        |: (field "path" string)
        |: (optionalField "url" string)


decodeTorrentStats : Decode.Decoder TorrentStats
decodeTorrentStats =
    succeed TorrentStats
        |: (field "downloaded" int)
        |: (field "speed" float)
        |: (field "progress" float)


decodeStatus : String -> Decode.Decoder DownloadStatus
decodeStatus status =
    succeed (stringToDownloadStatus status)


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


torrentDecoder : Decode.Decoder Torrent
torrentDecoder =
    succeed Torrent
        |: (field "name" string)
        |: (field "hash" string)
        |: (field "status" string |> Decode.andThen decodeStatus)
        |: (optionalField "stats" (Decode.field "stats" decodeTorrentStats))
        |: (field "files" (Decode.list decodeTorrentFile))


statusDecoder : Decode.Decoder String
statusDecoder =
    Decode.field "status" Decode.string


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


updateTorrentProgress : Torrent -> List Torrent -> List Torrent
updateTorrentProgress parsedTorrent modelTorrents =
    updateIf (\torrent -> torrent.hash == parsedTorrent.hash) (\torrent -> parsedTorrent) modelTorrents


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { connectionStatus, currentLink, torrents } =
    case msg of
        Input newInput ->
            ( Model connectionStatus newInput torrents, Cmd.none )

        Send ->
            ( Model connectionStatus "" torrents, WebSocket.send websocketURL currentLink )

        NewMessage str ->
            case str of
                "Connection established" ->
                    ( Model Online currentLink torrents, Cmd.none )

                _ ->
                    let
                        status =
                            Decode.decodeString statusDecoder str

                        _ =
                            Debug.log "Status " status
                    in
                        case status of
                            Ok "download:start" ->
                                -- type alias Torrent =
                                --     { name : String
                                --     , hash : String
                                --     , status : DownloadStatus
                                --     , stats : Maybe TorrentStats
                                --     , files : List TorrentFile
                                --     }
                                ( Model connectionStatus currentLink ((decodeTorrent str) :: torrents), Cmd.none )

                            Ok "download:progress" ->
                                ( Model connectionStatus currentLink (updateTorrentProgress (decodeTorrent str) torrents), Cmd.none )

                            Ok "download:complete" ->
                                ( Model connectionStatus currentLink (updateTorrentProgress (decodeTorrent str) torrents), Cmd.none )

                            Ok _ ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )

                            Err _ ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen websocketURL NewMessage



-- VIEW


onClickNoDefault : msg -> Attribute msg
onClickNoDefault message =
    let
        config =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "click" config (Decode.succeed message)


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ]
                [ p
                    [ class
                        ("title is-2 "
                            ++ if model.connectionStatus == Online then
                                "lit"
                               else
                                "meh"
                        )
                    ]
                    [ text "Torrent to Dropbox" ]
                , p [ class "subtitle is-5" ]
                    [ text "Dowload torrents straight to your Dropbox" ]
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ]
                [ Html.form []
                    [ div [ class "field" ]
                        [ p [ class "control has-icon" ]
                            [ input [ class "input is-primary", id "magnet_link", name "magnet", placeholder "Enter magnet URI", type_ "text", onInput Input ]
                                []
                            , span
                                [ class "icon is-small" ]
                                [ i [ class "fa fa-magnet", attribute "aria-hidden" "true" ]
                                    []
                                ]
                            ]
                        ]
                    , div [ class "field" ]
                        [ p [ class "control" ]
                            [ label [ class "checkbox" ]
                                [ input [ type_ "checkbox" ]
                                    []
                                , text "Upload to Dropbox"
                                ]
                            ]
                        ]
                    , div [ class "form-group" ]
                        [ button [ class "button is-primary is-medium", onClickNoDefault Send ]
                            [ text "Download" ]
                        ]
                    ]
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ]
                [ p [ class "title is-3" ]
                    [ text "Torrents" ]
                , div [ class "box" ]
                    [ article [ class "media" ]
                        [ div [ class "media-content" ]
                            [ div [ class "content" ]
                                [ div [ class "columns" ]
                                    [ div [ class "column is-9" ]
                                        [ p []
                                            [ strong []
                                                [ text "Leaves of Grass by Walt Whitman" ]
                                            , br []
                                                []
                                            , small []
                                                [ text "#955f3d891dfc792a8a957e8c97e54d25f2695d9d" ]
                                            , br []
                                                []
                                            , progress [ class "progress is-info", Html.Attributes.max "100", Html.Attributes.value "45" ]
                                                [ text "45%" ]
                                            ]
                                        ]
                                    , div [ class "column" ]
                                        [ div [ class "columns" ]
                                            [ a [ class "column" ]
                                                [ text "Files"
                                                , span [ class "icon" ]
                                                    [ i [ class "fa fa-file" ]
                                                        []
                                                    ]
                                                ]
                                            , a [ class "column" ]
                                                [ text "Start"
                                                , span [ class "icon" ]
                                                    [ i [ class "fa fa-cloud-download" ]
                                                        []
                                                    ]
                                                ]
                                            , a [ class "column" ]
                                                [ text "Delete"
                                                , span [ class "icon" ]
                                                    [ i [ class "fa fa-trash-o" ]
                                                        []
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
