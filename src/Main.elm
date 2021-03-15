module Main exposing (..)

import Browser exposing (UrlRequest, Document)
import Features.HeroById as HeroById
import Features.HeroByName as HeroByName
import Features.StartUpPage as StartUpPage
import Features.Hero exposing (..)
import Features.Route as Route exposing (Route)
import Browser.Navigation as Nav
import Url exposing (Url)
import Html exposing (..)
import RemoteData exposing (WebData)
import Json.Decode as Decode exposing (decodeValue, decodeString, Value)
import Http

type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }

type Page
    = NotFoundPage
    | StartUpPage
    | HeroPageId HeroById.Model
    | HeroPageName HeroByName.Model

type Msg
    = HeroPageIdMsg HeroById.Msg
    | HeroPageNameMsg HeroByName.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url

init : Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }     
        
        heroes =
            case decodeValue Decode.string flags of
                Ok heroesJson ->
                    decodeStoredHeroes heroesJson
                Err _ ->
                    Http.BadBody "Flags must be either string or null"
                        |> RemoteData.Failure
    in
    
    initCurrentPage heroes ( model, Cmd.none )    

decodeStoredHeroes : String -> WebData (List Hero)
decodeStoredHeroes heroesJson =
    case decodeString heroesDecoder heroesJson of
        Ok heroes ->
            RemoteData.succeed heroes

        Err _ ->
            RemoteData.Loading

initCurrentPage : WebData (List Hero) -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage  heroes ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )
                
                Route.Start ->
                    (StartUpPage, Cmd.none)

                Route.HeroByID ->
                    let
                        ( pageModel, pageCmds ) =
                            HeroById.init
                    in
                    ( HeroPageId pageModel, Cmd.map HeroPageIdMsg pageCmds )

                Route.HeroByName ->
                    let
                        (pageModel, pageCmds) =
                            HeroByName.init heroes
                    in
                    ( HeroPageName pageModel, Cmd.map HeroPageNameMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( HeroPageIdMsg subMsg, HeroPageId pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    HeroById.update subMsg pageModel
            in
            ( { model | page = HeroPageId updatedPageModel }
            , Cmd.map HeroPageIdMsg updatedCmd
            )
        
        ( HeroPageNameMsg subMsg, HeroPageName pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    HeroByName.update subMsg pageModel
            in
            ( { model | page = HeroPageName updatedPageModel }
            , Cmd.map HeroPageNameMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage RemoteData.Loading

        ( _, _ ) ->
            ( model, Cmd.none )

view : Model -> Document Msg
view model =
    {title = "Hero App"
    , body = [currentView model]
    }

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        StartUpPage ->
            StartUpPage.startUpPageView

        HeroPageId pageModel ->
            HeroById.view pageModel
                |> Html.map HeroPageIdMsg
        
        HeroPageName pageModel ->
            HeroByName.view pageModel
                |> Html.map HeroPageNameMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested does not exist!" ]

---- PROGRAM ----

main : Program Value Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
