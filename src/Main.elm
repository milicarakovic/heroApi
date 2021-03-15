module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)
import Features.CombinedHero as CombinedHero


---- PROGRAM ----


main : Program () CombinedHero.Model CombinedHero.Msg
main =
    Browser.element
        { view = CombinedHero.view
        , init = CombinedHero.init
        , update = CombinedHero.update
        , subscriptions = always Sub.none
        }
