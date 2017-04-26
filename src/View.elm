module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Decode exposing (..)
import Model exposing (..)
import Messages exposing (Msg(..))


onClickNoDefault : msg -> Attribute msg
onClickNoDefault message =
    let
        config =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "click" config (Decode.succeed message)


showTorrents : Model -> Html Msg
showTorrents model =
    if (List.isEmpty model.torrents) then
        div [ class "box" ]
            [ article [ class "media" ]
                [ p
                    [ class "subtitle is-5" ]
                    [ text "Add Torrents Above" ]
                ]
            ]
    else
        div [ class "box" ]
            (List.map
                torrentTemplate
                model.torrents
            )


torrentTemplate : Torrent -> Html Msg
torrentTemplate torrent =
    article [ class "media" ]
        [ div [ class "media-content" ]
            [ div [ class "content" ]
                [ div [ class "columns" ]
                    [ div [ class "column is-9" ]
                        [ p []
                            [ strong []
                                [ text torrent.name ]
                            , br []
                                []
                            , small []
                                [ text torrent.hash ]
                            , br []
                                []
                            , progress
                                [ class "progress is-info"
                                , Html.Attributes.max "100"
                                , Html.Attributes.value
                                    (case torrent.stats of
                                        Nothing ->
                                            "0"

                                        Just { downloaded, speed, progress } ->
                                            toString (progress * 100)
                                    )
                                ]
                                [ text
                                    (case torrent.stats of
                                        Nothing ->
                                            "0 %"

                                        Just { downloaded, speed, progress } ->
                                            toString (progress * 100) ++ " %"
                                    )
                                ]
                            ]
                        ]
                    , div [ class "column" ]
                        [ div [ class "columns" ]
                            [ a [ class "column" ]
                                [ text "Files"
                                , span [ class "icon" ]
                                    [ i [ class "fa fa-file" ]
                                        []
                                    ]
                                ]
                            , a [ class "column" ]
                                [ text "Start"
                                , span [ class "icon" ]
                                    [ i [ class "fa fa-cloud-download" ]
                                        []
                                    ]
                                ]
                            , a [ class "column" ]
                                [ text "Delete"
                                , span [ class "icon" ]
                                    [ i [ class "fa fa-trash-o" ]
                                        []
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ]
                [ p
                    [ class
                        ("title is-2 "
                            ++ if model.connectionStatus == Model.Online then
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
        , div [ class "columns" ]
            [ div [ class "column is-8 is-offset-2" ]
                [ p [ class "title is-3" ]
                    [ text "Torrents" ]
                , showTorrents model
                ]
            ]
        ]
