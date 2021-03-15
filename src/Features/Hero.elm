module Features.Hero exposing (..)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (optional, optionalAt, required, requiredAt)
import Json.Encode as Encode
import Features.Ports exposing (storeHeroes)

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

heroDecoder : Decoder Hero
heroDecoder =
    Decode.succeed Hero    
        |> required "id" string
        |> required "name" string
        |> requiredAt ["biography", "full-name"] string
        |> requiredAt ["image", "url"] string

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


-- saveHero : Hero -> Cmd msg
-- saveHero hero =
--     Encode.object heroEncoder hero
--         |> Encode.encode 0
--         |> storeHeroes