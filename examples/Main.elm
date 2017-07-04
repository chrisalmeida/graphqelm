module Main exposing (..)

import Html as Html exposing (div, Html, text, button, h1)
import Html.Attributes exposing (id, class)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, at, map2, field, string)
import GraphQElm exposing (Query, gql, get, concatQueries, mutate)
import Http
import Examples.Css exposing (..)


type Msg
    = QueryGQL String
    | GQLResponse (Result Http.Error User)


type alias User =
    { name : String, email : String }


type alias Model =
    { user : User
    , error : String
    , gqlEndpoint : String
    }


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = (\_ -> Sub.none)
        , update = update
        , view = view
        }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { user = { email = "", name = "" }
    , error = ""
    , gqlEndpoint = "http://localhost:4000/graphql"
    }



-- find a user by email


userQuery : Query
userQuery =
    { resource = "user"
    , fields = [ "email", "name" ]
    , args = [ ( "email", "1@1.com" ) ]
    , alias = ""
    }


userDecoder : Decoder User
userDecoder =
    at [ "data", "user" ]
        (map2 User (field "name" string) (field "email" string))


update : Msg -> Model -> ( Model, Cmd Msg )
update m model =
    case m of
        QueryGQL query ->
            ( model
            , Http.send (\res -> GQLResponse res) (get model.gqlEndpoint query userDecoder)
            )

        GQLResponse (Ok user) ->
            ( { model | user = user }, Cmd.none )

        GQLResponse (Err err) ->
            ( { model | error = toString err }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        query =
            gql userQuery
    in
        div [ containerCSS ]
            [ h1 [] [ text "GraphQElm Query:" ]
            , text query
            , button [ buttonCSS, onClick (QueryGQL query) ] [ text "Send GQL" ]
            , div [ containerCSS ] [ h1 [] [ text "Model:" ], text (toString model) ]
            ]
