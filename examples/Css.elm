module Examples.Css exposing (..)

import Html.Attributes exposing (style)
import Html exposing (Attribute)


containerCSS : Html.Attribute msg
containerCSS =
    style
        [ ( "height", "100vh" )
        , ( "text-align", "center" )
        , ( "margin", "10% auto" )
        , ( "font-family", "avenir next" )
        , ( "width", "100vw" )
        ]


buttonCSS : Html.Attribute msg
buttonCSS =
    style
        [ ( "background", "#3498db" )
        , ( "margin", "2% auto" )
        , ( "height", "50px" )
        , ( "border", "none" )
        , ( "width", "100px" )
        , ( "display", "block" )
        , ( "color", "white" )
        ]
