module View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onWithOptions)
import Json.Decode as Decode exposing (..)
import Messages exposing (Msg(..))
import Model exposing (..)


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
    if Dict.isEmpty model.torrents then
        div [ class "box" ]
            [ article [ class "media" ]
                [ p
                    [ class "subtitle is-5" ]
                    [ text "Add Torrents Above" ]
                ]
            ]

    else
        div []
            [ div [ class "box" ]
                (List.map
                    (torrentTemplate model)
                    (Dict.values model.torrents)
                )
            ]


showFile : Model -> TorrentFile -> Html Msg
showFile model file =
    let
        fileDownloadURL =
            model.backendURL ++ "/download?file=" ++ file.path
    in
    div [ class "columns" ]
        [ p [ class "column" ] [ text file.name ]
        , div [ class "column" ]
            [ a
                [ href fileDownloadURL, class "dropbox-saver dropbox-dropin-btn dropbox-dropin-default" ]
                [ span [ class "dropin-btn-status" ]
                    []
                , text "Save to Dropbox"
                ]
            ]
        ]


torrentTemplate : Model -> Torrent -> Html Msg
torrentTemplate model torrent =
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

                                        Just { progress } ->
                                            toString (progress * 100)
                                    )
                                ]
                                [ text
                                    (case torrent.stats of
                                        Nothing ->
                                            "0 %"

                                        Just { progress } ->
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
                                [ text "Delete"
                                , span [ class "icon" ]
                                    [ i [ class "fa fa-trash-o" ]
                                        []
                                    ]
                                ]
                            ]
                        ]
                    ]
                , div []
                    (List.map
                        (showFile model)
                        torrent.files
                    )
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
                            ++ (if model.connectionStatus == Model.Online then
                                    "lit"

                                else
                                    "meh"
                               )
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
