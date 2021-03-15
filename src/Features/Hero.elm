module Features.Hero exposing (..)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (optionalAt, required, requiredAt)
import Json.Encode as Encode

type HeroId
    = HeroId Int

   
type alias Hero =
    { id : String
    , name : String
    , fullName : String
    , imageUrl : String
    }

initialHeroId : HeroId
initialHeroId =
    HeroId -1

initialHero : Hero
initialHero =
    { id = ""
    , name = ""
    , fullName =""
    , imageUrl =""
    }

idDecoder : Decoder HeroId
idDecoder =
    Decode.map HeroId int

heroesDecoder : Decoder (List Hero)
heroesDecoder =
    Decode.succeed identity
        |> required "results" (list heroDecoder)


heroDecoder : Decoder Hero
heroDecoder =
    Decode.succeed Hero    
        |> required "id" string
        |> required "name" string
        |> requiredAt ["biography", "full-name"] string
        |> optionalAt ["image", "url"] string "https://bitsofco.de/content/images/2018/12/broken-1.png"

idToString : HeroId -> String
idToString (HeroId id) =
    String.fromInt id

encodeId : HeroId -> Encode.Value
encodeId (HeroId id) =
    Encode.int id

heroEncoder : Hero -> Encode.Value
heroEncoder hero =
    Encode.object
        [ ( "id", Encode.string hero.id )
        , ( "name", Encode.string hero.name )
        , ( "fullName", Encode.string hero.fullName )
        , ( "imageUrl", Encode.string hero.imageUrl )
        ]
