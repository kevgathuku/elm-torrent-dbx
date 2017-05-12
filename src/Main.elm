module Main exposing (..)

import Html  exposing (Html)
import Model
import Update
import View


main =
    Html.programWithFlags
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = Update.subscriptions
        }
