module Features.HeroByName exposing (..)
import Features.Hero exposing(..)
import Features.Error exposing (buildErrorMessage)
import RemoteData exposing (WebData)
import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

type Size = Small | Large

type alias Model =
    { heroes : WebData (List Hero)
    , searchString : String
    , imageSize : Size
    }

type Msg
    = FetchHeroes
    | HeroesReceived (WebData (List Hero))
    | SetSearchString String
    | ChangeSizeLarge
    | ChangeSizeSmall

init : WebData (List Hero) -> (Model, Cmd Msg)
init heroes =
    (initialModel heroes, fetchHeroes "spider")

initialModel : WebData (List Hero) -> Model
initialModel heroes =
    { heroes = heroes
    , searchString = ""
    , imageSize = Small
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

        ChangeSizeLarge ->
            ({model | imageSize = Large}, Cmd.none)
        
        ChangeSizeSmall ->
            ({model | imageSize = Small}, Cmd.none)
        
-- VIEW
view : Model -> Html Msg
view model =
    div ([] ++ pageStyle)
        [ input ([onInput SetSearchString, placeholder "Spider" ] ++ inputStyle) []
        , button ([ onClick FetchHeroes ] ++ buttonStyle)
            [ text "Search hero by name" ]
        , br [] []
        , br [] []
        , div []
            [ text "Choose image size: "  
            , radio (model.imageSize == Small) ChangeSizeSmall "Small"
            , radio (model.imageSize == Large) ChangeSizeLarge "Large"
            ]
        , br [] []
        , viewHeroes model.imageSize model.heroes
        ]

radio : Bool-> msg -> String -> Html msg
radio isChecked msg name =
    label
        [ style "padding" "20px" ]
        [ input [ type_ "radio", onClick msg, checked isChecked] []
        , text name
        ]

viewHeroes : Size -> WebData (List Hero) -> Html Msg
viewHeroes size heroes =
    case heroes of        
        RemoteData.NotAsked ->
            text "Not asked"
        
        RemoteData.Loading ->
            h3 [] [ text "Loading..." ]
        
        RemoteData.Success actualHeroes ->
            div [] 
                [ table ([] ++ tableStyle) 
                    ([viewTableHeader] ++ List.map (viewHero size) actualHeroes)
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

viewHero :  Size -> Hero -> Html Msg
viewHero size hero =
        let
            style =
                case size of
                   Small -> smallImageStyle
                   Large -> bigImageStyle
        in
        tr []
        [ td []
            [ text hero.id ]
        , td []
            [ text hero.name ]
        , td []
            [ text hero.fullName ]
        , td []
           [ img ([src hero.imageUrl] ++ style) []]
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

smallImageStyle : List (Attribute msg)
smallImageStyle =
    [ style "height" "60px"
    , style "width" "60px"
    ]

bigImageStyle : List (Attribute msg)
bigImageStyle =
    [ style "height" "90px"
    , style "width" "90px"
    ]