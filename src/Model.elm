module Model exposing (..)

import Dict
import Messages exposing (Msg)


type alias Model =
    { connectionStatus : ConnectionStatus
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


init : ( Model, Cmd Msg )
init =
    ( Model Offline "" Dict.empty, Cmd.none )
