module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick)
import Http
import WebSocket


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


websocketURL : String
websocketURL =
    "ws://localhost:4000"


type alias Model =
    { input : String
    , messages : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], Cmd.none )



-- UPDATE


type Msg
    = Input String
    | Send
    | NewMessage String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { input, messages } =
    case msg of
        Input newInput ->
            ( Model newInput messages, Cmd.none )

        Send ->
            ( Model "" messages, WebSocket.send websocketURL input )

        NewMessage str ->
            ( Model input (str :: messages), Cmd.none )



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
                [ p [ class "title is-2" ]
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
                            [ input [ class "input is-primary", id "magnet_link", name "magnet", placeholder "Enter magnet URI", type_ "text" ]
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
                        [ button [ class "button is-primary is-medium", type_ "submit" ]
                            [ text "Download" ]
                        ]
                    ]
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ] (List.map viewMessage model.messages)
            , input [ onInput Input ] []
            , button [ onClick Send ] [ text "Send" ]
            ]
        ]


viewMessage : String -> Html msg
viewMessage msg =
    div [] [ text msg ]
