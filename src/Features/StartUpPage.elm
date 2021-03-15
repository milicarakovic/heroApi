module Features.StartUpPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

viewHeader : Html msg
viewHeader =
    tr []
        [ th [] [text "Description"]
        , th [] [text "Link to a page"]
        ]


startUpPageView : Html msg
startUpPageView =
    div []
    [ h2 [] [ text "Welcome to Elm app!" ]
    , h4 [] [ text "We are going to test SuperHeroApi..." ]
    , br [] []
    , br [] []
    , table ([] ++ tableStyle)
        [viewHeader
        , tr []
            [td [] [pre [] [text "If you want to search heroes by ID,\nthen go to this link --->"]]
            ,td [] [a [ href "/heroById" ] [ text "Hero_ID" ] ]
            ]
        , tr []
            [td [] [pre [] [text "If you want to search heroes by NAME,\nthen go to this link --->"]]
            ,td [] [a [ href "/heroByName" ] [ text "Hero_NAME" ] ]
            ]
        ]
    ]

-- STYLE

tableStyle : List (Attribute msg)
tableStyle =
    [ style "margin" "auto"
    ]