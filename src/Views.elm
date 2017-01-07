module Views exposing (..)

-- External Imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String
import Tuple

-- Internal Imports

import Types exposing (..)
import Utils.Date exposing (..)
import Utils.Views exposing (..)
import Silences.Views


view : Model -> Html Msg
view model =
    case model.route of
        AlertGroupsRoute ->
            genericListView alertGroupsView model.alertGroups

        NewSilenceRoute ->
            silenceFormView "New" model.silence

        EditSilenceRoute id ->
            silenceFormView "Edit" model.silence

        SilencesRoute ->
            genericListView silenceListView model.silences

        SilenceRoute name ->
            Silences.Views.silenceView model.silence

        _ ->
            notFoundView model


todoView : a -> Html Msg
todoView model =
    div []
        [ h1 [] [ text "todo" ]
        ]



-- Start
-- End
-- Matchers (Name, Value, Regexp) and add additional
-- Creator
-- Comment
-- Create


silenceFormView : String -> Silence -> Html Msg
silenceFormView kind silence =
    div [ class "pa4 black-80" ]
        [ fieldset [ class "ba b--transparent ph0 mh0" ]
            [ legend [ class "ph0 mh0 fw6" ] [ text <| kind ++ " Silence" ]
            , formField "Start" silence.startsAt
            -- , dateTimePicker "Start"
            , formField "End" silence.endsAt
            , div [ class "mt3" ]
                [ label [ class "f6 b db mb2" ] [ text "Matchers "
                , span [class "normal black-60"] [ text "Alerts affected by this silence." ]
                ]
                , label [ class "f6 dib mb2 mr2 w-40" ] [ text "Name" ]
                , label [ class "f6 dib mb2 mr2 w-40" ] [ text "Value" ]
                , matcherForm <| Matcher "device" "/dev/xda1" True
                ]
            , formField "Creator" silence.createdBy
            , textField "Comment" silence.comment
            , div [ class "mt3" ]
                [ a [ class "f6 link br2 ba ph3 pv2 mr2 dib dark-blue", href "#0"] [ text "Create" ]
                , a [ class "f6 link br2 ba ph3 pv2 mb2 dib dark-red", href "#0"] [ text "Reset" ]
                ]
            ]
        ]


matcherForm : Matcher -> Html msg
matcherForm matcher =
    div [] [ input [ class "input-reset ba br1 b--black-20 pa2 mb2 mr2 dib w-40", value matcher.name ] []
    , input [ class "input-reset ba br1 b--black-20 pa2 mb2 mr2 dib w-40", value matcher.value ] []
    , checkbox "Regex" matcher.isRegex
    ]


checkbox : String -> Bool -> Html msg
checkbox name status =
    label [ class "f6 dib mb2" ]
        [ input [ type_ "checkbox", checked status ] []
        , text <| " " ++ name
        ]

formField : String -> String -> Html msg
formField labelText content =
    div [ class "mt3" ]
        [ label [ class "f6 b db mb2" ] [ text labelText ]
        , input [ class "input-reset ba br1 b--black-20 pa2 mb2 db w-100", value content ] []
        ]

textField : String -> String -> Html msg
textField labelText content =
    div [ class "mt3" ]
        [ label [ class "f6 b db mb2" ] [ text labelText ]
        , textarea [ class "db border-box hover-black w-100 ba b--black-20 pa2 br1 mb2", value content ] []
        ]

alertGroupsView : AlertGroup -> Html Msg
alertGroupsView alertGroup =
    li [ class "pa3 pa4-ns bb b--black-10" ]
        [ div [ class "mb3" ] (List.map alertHeader <| List.sort alertGroup.labels)
        , div [] (List.map blockView alertGroup.blocks)
        ]


blockView : Block -> Html msg
blockView block =
    -- Block level
    div []
        (List.map alertView block.alerts)


alertView : Alert -> Html msg
alertView alert =
    let
        id =
            case alert.silenceId of
                Just id ->
                    id

                Nothing ->
                    0

        b =
            if alert.silenced then
                buttonLink "fa-deaf" ("#/silences/" ++ toString id) "dark-blue"
            else
                buttonLink "fa-exclamation-triangle" "#/silences/new" "dark-red"
    in
        div [ class "f6 mb3" ]
            [ div [ class "mb1" ]
                [ b
                , buttonLink "fa-bar-chart" alert.generatorUrl "black"
                , p [ class "dib mr2" ] [ text <| Utils.Date.dateFormat alert.startsAt ]
                ]
            , div [ class "mb2 w-80-l w-100-m" ] (List.map labelButton <| List.filter (\( k, v ) -> k /= "alertname") alert.labels)
            ]


buttonLink : String -> String -> String -> Html msg
buttonLink icon link color =
    a [ class <| "f6 link br1 ba mr1 ph3 pv2 mb2 dib " ++ color, href link ]
        [ i [ class <| "fa fa-3 " ++ icon ] []
        ]


alertHeader : ( String, String ) -> Html msg
alertHeader ( key, value ) =
    if key == "alertname" then
        b [ class "db f4 mr2 dark-red dib" ] [ text value ]
    else
        listButton "ph1 pv1" ( key, value )


notFoundView : a -> Html Msg
notFoundView model =
    div []
        [ h1 [] [ text "not found" ]
        ]


genericListView : (a -> Html Msg) -> List a -> Html Msg
genericListView fn list =
    ul
        [ classList
            [ ( "list", True )
            , ( "pa0", True )
            ]
        ]
        (List.map fn list)


silenceListView : Silence -> Html Msg
silenceListView silence =
    let
        -- TODO: Check with fabxc if the alert being in the first position can
        -- be relied upon.
        alertName =
            case List.head silence.matchers of
                Just m ->
                    m.value

                Nothing ->
                    ""
    in
        li
            [ class "pa3 pa4-ns bb b--black-10" ]
            [ a
                [ class "db link blue"
                , href ("#/silences/" ++ (toString silence.id))
                ]
                [ b [ class "db f4 mb1" ]
                    [ text alertName ]
                ]
            , span [ class "f5 db lh-copy measure" ]
                [ text silence.createdBy ]
            , span [ class "f5 db lh-copy measure" ]
                [ text silence.comment ]
            ]
