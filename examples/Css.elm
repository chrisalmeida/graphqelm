module Examples.Css exposing (..)

import Html.Attributes exposing (style)
import Html exposing (Attribute)


containerCSS : Html.Attribute msg
containerCSS =
    style
        [ ( "height", "100vh" )
        , ( "text-align", "center" )
        , ( "margin", "10% auto" )
        , ( "font-family", "Avenir Next, Avenir, Arial, Helvetica, sans-serif" )
        , ( "width", "100vw" )
        , ( "position", "absolute" )
        ]


buttonCSS : String -> Html.Attribute msg
buttonCSS color =
    let
        c =
            if color == "green" then
                "#1ABC9C"
            else
                "#3498db"
    in
        style
            [ ( "background", c )
            , ( "margin", "2% auto" )
            , ( "height", "50px" )
            , ( "border", "none" )
            , ( "width", "100px" )
            , ( "display", "block" )
            , ( "color", "white" )
            ]


formCSS : Html.Attribute msg
formCSS =
    style
        [ ( "width", "50%" )
        , ( "margin", "0 auto" )
        , ( "text-align", "center" )
        ]


formGroupCSS : Html.Attribute msg
formGroupCSS =
    style
        [ ( "width", "100%" )
        , ( "text-align", "center" )
        ]


formInputCSS : Html.Attribute msg
formInputCSS =
    style
        [ ( "display", "block" )
        , ( "width", "70%" )
        , ( "margin", "2% auto" )
        , ( "border", "none" )
        , ( "border-bottom", "1px solid black" )
        , ( "outline", "none" )
        , ( "padding-bottom", "1%" )
        , ( "text-align", "center" )
        , ( "font-size", "1rem" )
        ]


navCSS =
    style
        [ ( "position", "absolute" )
        , ( "top", "0" )
        , ( "background", "#1ABC9C" )
        , ( "width", "100%" )
        , ( "height", "60px" )
        , ( "text-align", "center" )
        , ( "color", "white" )
        , ( "padding-bottom", "20px" )
        , ( "font-family", "Avenir Next, Avenir, Arial, Helvetica, sans-serif" )
        ]
