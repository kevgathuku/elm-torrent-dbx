module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    Int


model : Model
model =
    0



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col-sm-7 col-sm-offset-3" ]
                [ h3 []
                    [ span [ attribute "aria-hidden" "true", class "glyphicon glyphicon-save title-icon" ]
                        []
                    , text "Torrent to Dropbox"
                    ]
                ]
            ]
        , div [ class "row" ]
            [ Html.form [ class "form-horizontal" ]
                [ div [ class "form-group" ]
                    [ div [ class "col-sm-7 col-sm-offset-3" ]
                        [ input [ class "form-control", id "magnet_link", name "magnet", placeholder "Enter magnet URI", type_ "text" ]
                            []
                        , text ""
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-sm-7 col-sm-offset-3" ]
                        [ div [ class "checkbox" ]
                            [ label []
                                [ input [ type_ "checkbox" ]
                                    []
                                , text " Upload to Dropbox"
                                ]
                            ]
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-sm-7 col-sm-offset-3" ]
                        [ button [ class "btn btn-primary", type_ "submit" ]
                            [ text "Download" ]
                        ]
                    ]
                ]
            ]
        ]
