module KindleBook exposing (ASIN, KindleBook, SeriesName)

import Date exposing (Date)


type alias KindleBook =
    { id : ASIN
    , rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : SeriesName
    , authors : List String
    , img : String -- 書影画像URL
    , acquiredDate : Date
    }


type alias ASIN =
    String


type alias SeriesName =
    String
