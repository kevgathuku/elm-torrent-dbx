module Main exposing (..)

import TimeTravel.Html as TimeTravel
import Model
import Update
import View


main =
    TimeTravel.program
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = Update.subscriptions
        }
