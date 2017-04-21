module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Decode exposing (succeed, string, int, float, field, nullable, list, maybe)
import Json.Encode as Encode
import Json.Decode.Extra exposing ((|:))
import WebSocket


main =
    Html.program
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
    , speed : Int
    , progress : Float
    }


type alias TorrentFile =
    { name : String
    , length : Int
    , path : String
    , url : String
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
        |: (field "url" string)


decodeTorrentStats : Decode.Decoder TorrentStats
decodeTorrentStats =
    succeed TorrentStats
        |: (field "downloaded" int)
        |: (field "speed" int)
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
        |: (field "stats" (maybe decodeTorrentStats))
        |: (field "files" (Decode.list decodeTorrentFile))


statusDecoder : Decode.Decoder String
statusDecoder =
    Decode.field "status" Decode.string


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
                                --
                                --
                                --
                                -- type alias Torrent =
                                --     { name : String
                                --     , hash : String
                                --     , status : DownloadStatus
                                --     , stats : Maybe TorrentStats
                                --     , files : List TorrentFile
                                --     }
                                ( Model connectionStatus currentLink torrents, Cmd.none )

                            Ok "download:progress" ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )

                            Ok "download:complete" ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )

                            Ok _ ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )

                            Err _ ->
                                ( Model connectionStatus currentLink torrents, Cmd.none )


addStartedTorrent : String -> List Torrent -> List Torrent
addStartedTorrent status torrents =
    Torrent "" "" Started Nothing [] :: torrents



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen websocketURL NewMessage



-- VIEW


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
        ]


onClickNoDefault : msg -> Attribute msg
onClickNoDefault message =
    let
        config =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "click" config (Decode.succeed message)
