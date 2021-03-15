module Features.CombinedHero exposing (..)
import Features.Hero exposing (heroDecoder)
import RemoteData exposing (WebData)
import Features.Error exposing (buildErrorMessage)
import Features.Hero as Hero exposing (Hero)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import RemoteData exposing (RemoteData(..))
import Debug

type alias Model =
    { hero : WebData (Hero)
    , randomId : String
    }

type Msg
    = FetchHero
    | HeroReceived (WebData Hero)
    | SetNewId String

initialModel : WebData (Hero) -> Model
initialModel hero =
    { hero = hero, randomId = "1" }

init : () -> (Model, Cmd Msg)
init _ = ({hero = Loading, randomId = "1"}, fetchHero "1")

fetchHero : String ->  Cmd Msg
fetchHero number =
    Http.get
        { url = "http://localhost:3000/" ++ number
        , expect =
            heroDecoder
                |> Http.expectJson (RemoteData.fromResult >> HeroReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchHero ->
            let

                idToSearch =
                    case String.toInt model.randomId of
                        Just number ->
                            model.randomId
                        Nothing  ->
                            "1"         

            in
            ( { model | hero = RemoteData.Loading }, fetchHero idToSearch)

        HeroReceived response ->
            ( { model | hero = response }, Cmd.none )

        SetNewId newIdStr ->
            ({model | randomId = newIdStr}, Cmd.none)

view : Model -> Html Msg
view model =
    div ([] ++ pageStyle)
        [ input ([onInput SetNewId ] ++ inputStyle) []
        , button ([ onClick FetchHero ] ++ buttonStyle)
            [ text "Search hero by id" ]
        , br [] []
        , br [] []
        , viewHero model.hero
        ]


viewHero : WebData (Hero) -> Html Msg
viewHero hero =
    case hero of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]

        RemoteData.Success actualHero ->
            div ([] ++ leftAndRight)
                [ div ([] ++ leftStyle) 
                    [
                         div ([] ++ divStyle) 
                    [
                        h4 [] [text "ID:"]
                        , h3 [] [text ( actualHero.id)]
                    ]
                , div ([] ++ divStyle) 
                    [
                        h4 [] [text "Name:"]
                        , h3 [] [text ( actualHero.name)]
                    ]
                , div ([] ++ divStyle)  
                    [
                        h4 [] [text "Full name:"]
                        ,h3 [] [text ( actualHero.fullName)]
                    ] 
                    ]
                , img ([src actualHero.imageUrl] ++ rightStyle) []
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

leftAndRight : List (Attribute msg)
leftAndRight =
    [ style "paddingLeft" "10%"
    , style "paddingRight" "10%"
    , style "border" "solid 1px"
    , style "backgroundColor" "#EAFEFE"
    ]

pageStyle : List (Attribute msg)
pageStyle =
    [ style "margin" "5% 5% 5% 5%"
    -- , style "backgroundColor" "green"
    ]

leftStyle : List (Attribute msg)
leftStyle =
    [ style "float" "left"
    , style "marginTop" "5%"
    -- , style "backgroundColor" "red"
    ]

rightStyle : List (Attribute msg)
rightStyle =
    [ style "overflow" "hidden"
    -- , style "backgroundColor" "pink"
    -- , style "padding" "10px"
    ]


divStyle : List (Attribute msg)
divStyle =
    [ style "display" "flex"
    , style "justifyContent" "center"
    , style "columnGap" "20px"
    -- , style "backgroundColor" "yellow"
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
    , style "background-color" "#397cd5"
    , style "color" "white"
    , style "padding" "14px 20px"
    , style "margin-top" "10px"
    , style "border" "none"
    , style "border-radius" "4px"
    , style "font-size" "16px"
    ]