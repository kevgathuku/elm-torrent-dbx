module Model exposing (..)

import Messages exposing (Msg)


type ConnectionStatus
    = Offline
    | Online


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


type alias Model =
    { connectionStatus : ConnectionStatus
    , currentLink : String
    , torrents : List Torrent
    }


init : ( Model, Cmd Msg )
init =
    ( Model Offline "" [], Cmd.none )
