module Main exposing (..)

import Html as Html exposing (div, Html, text, button)
import Html.Events exposing (onClick)
import Json.Decode exposing (..)
import GraphQElm exposing (Query, gql, get, concatQueries, mutate)
import Http


type Msg
    = QueryGQL String
    | Succ (Result Http.Error User)


company : Query
company =
    { resource = "company"
    , fields = [ "id" ]
    , args = []
    , alias = ""
    }


qu : Query
qu =
    { resource = "user"
    , fields = [ "email", "id" ]
    , args = [ ( "email", "1@1.com" ) ]
    , alias = ""
    }


type alias Model =
    { route : User }


model : Model
model =
    { route = { email = "", id = "" }
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


type alias User =
    { id : String, email : String }


usersDecoder : Decoder (List User)
usersDecoder =
    at [ "data", "users" ] (list (map2 User (field "id" string) (field "email" string)))


userDecoder : Decoder User
userDecoder =
    at [ "data", "user" ] (map2 User (field "id" string) (field "email" string))


update : Msg -> Model -> ( Model, Cmd Msg )
update m model =
    case m of
        QueryGQL q ->
            ( model, Http.send (\res -> Succ res) (get "http://localhost:4000/graphql" q (userDecoder)) )

        Succ (Ok res) ->
            ( { model | route = res }, Cmd.none )

        Succ (Err err) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        q =
            gql qu
    in
        div []
            [ text (concatQueries [ q, (gql company) ])
            , button [ onClick (QueryGQL q) ] [ text "Send GQL" ]
            , div [] [ text (toString model) ]
            ]


main : Program Never Model Msg
main =
    Html.program { init = init, subscriptions = (\_ -> Sub.none), update = update, view = view }
