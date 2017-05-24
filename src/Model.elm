module Model exposing (..)

import Dict
import Messages exposing (Msg)


type alias Model =
    { connectionStatus : ConnectionStatus
    , websocketURL : String
    , currentLink : String
    , torrents : Dict.Dict String Torrent
    }


type ConnectionStatus
    = Offline
    | Online


type alias Torrent =
    { name : String
    , hash : String
    , status : DownloadStatus
    , stats : Maybe TorrentStats
    , files : List TorrentFile
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


type alias Flags =
    { ws_url : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model Offline flags.ws_url "" Dict.empty, Cmd.none )
