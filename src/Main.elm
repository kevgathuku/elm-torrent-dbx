module Main exposing (..)

import Browser
import Html exposing (Html)
import Model
import Update
import View


main =
    Browser.element
        { init = Model.init
        , view = View.view
        , update = Update.update
        , subscriptions = Update.subscriptions
        }
