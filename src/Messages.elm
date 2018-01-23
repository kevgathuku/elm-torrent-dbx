module Messages exposing (..)


type Msg
    = Input String
    | Send
    | NewMessage String
    | SendToDropbox String
