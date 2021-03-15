module Features.HeroByName exposing (..)
import Features.Hero exposing(..)
import Features.Error exposing (buildErrorMessage)
import RemoteData exposing (WebData)
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

type alias Model =
    { heroes : WebData (List Hero)
    , searchString : String
    }

type Msg
    = FetchHeroes
    | HeroesReceived (WebData (List Hero))
    | SetSearchString String

init : WebData (List Hero) -> (Model, Cmd Msg)
init heroes =
    (initialModel heroes, fetchHeroes "spider")

initialModel : WebData (List Hero) -> Model
initialModel heroes =
    { heroes = heroes
    , searchString = ""
    }

fetchHeroes : String -> Cmd Msg
fetchHeroes searchStr =
    Http.get
        { url = "http://localhost:3000/name/" ++ searchStr
        , expect =
            heroesDecoder
                |> Http.expectJson (RemoteData.fromResult >> HeroesReceived)
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetSearchString newSearchString ->
            ({model | searchString = newSearchString}, Cmd.none)

        FetchHeroes ->
            ({model | heroes = RemoteData.Loading}, fetchHeroes model.searchString)
        
        HeroesReceived response ->
            ({model | heroes = response}, Cmd.none)
        
-- VIEW
view : Model -> Html Msg
view model =
    div ([] ++ pageStyle)
        [ input ([onInput SetSearchString, placeholder "Spider" ] ++ inputStyle) []
        , button ([ onClick FetchHeroes ] ++ buttonStyle)
            [ text "Search hero by name" ]
        , br [] []
        , br [] []
        , viewHeroes model.heroes
        ]

viewHeroes : WebData (List Hero) -> Html Msg
viewHeroes heroes =
    case heroes of        
        RemoteData.NotAsked ->
            text "Not asked"
        
        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]
        
        RemoteData.Success actualHeroes ->
            div [] 
                [ table ([] ++ tableStyle) 
                    ([viewTableHeader] ++ List.map viewHero actualHeroes)
                ]

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)

viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch posts at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]

viewTableHeader : Html Msg
viewTableHeader =
    tr ([] ++ tableHeadStyle)
        [ th []
            [ text "ID" ]
        , th []
            [ text "Name" ]
        , th []
            [ text "Full name" ]
        , th []
            [ text "Image" ]
        ]

viewHero :  Hero -> Html Msg
viewHero hero =
        tr []
        [ td []
            [ text hero.id ]
        , td []
            [ text hero.name ]
        , td []
            [ text hero.fullName ]
        , td []
           [ img ([src hero.imageUrl] ++ imageStyle) []]
        ]

-- STYLE

pageStyle : List (Attribute msg)
pageStyle =
    [ style "margin" "5% 5% 5% 5%"
    ]

inputStyle : List (Attribute msg)
inputStyle =
    [ style "display" "block"
    , style "width" "260px"
    , style "padding" "12px 20px"
    , style "margin" "auto"
    , style "border" "solid 1px"
    , style "border-radius" "4px"
    ]


buttonStyle : List (Attribute msg)
buttonStyle =
    [ style "width" "300px"
    , style "background-color" "#6b9292"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]

tableHeadStyle : List (Attribute msg)
tableHeadStyle =
    [ style "height" "35px"
    , style "background-color" "#068787"
    ]

tableStyle : List (Attribute msg)
tableStyle =
    [ style "margin" "auto"
    , style "width" "70%"
    ]

imageStyle : List (Attribute msg)
imageStyle =
    [ style "height" "60px"
    , style "width" "60px"
    ]