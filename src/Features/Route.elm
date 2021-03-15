module Features.Route exposing (..)

import Url exposing (Url)
import Url.Parser exposing (..)

type Route
    = NotFound
    | HeroByID
    | HeroByName
    | Start

parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route
        
        Nothing ->
            NotFound

matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Start top
        , map HeroByID (s "heroById")
        , map HeroByName (s "heroByName")
        ]

