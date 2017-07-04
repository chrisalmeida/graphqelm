module Main exposing (..)

import Html as Html exposing (div, Html, text, button)
import Html.Events exposing (onClick)
import Json.Decode exposing (Decoder, at, map2, field, string)
import GraphQElm exposing (Query, gql, get)
import Http


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



-- add an empty user to the model and our GraphQL endpoint to query


model : Model
model =
    { user = { email = "", name = "" }
    , error = ""
    , gqlEndpoint = "http://localhost:4000/graphql"
    }



-- create a query record to find a user by email
-- "user(email: me@example.com){email, name}"


userQuery : Query
userQuery =
    { resource = "user"
    , fields = [ "email", "name" ]
    , args = [ ( "email", "me@example.com" ) ]
    , alias = ""
    }



-- decode gql response


userDecoder : Decoder User
userDecoder =
    at [ "data", "user" ]
        (map2 User (field "name" string) (field "email" string))


update : Msg -> Model -> ( Model, Cmd Msg )
update m model =
    case m of
        -- use get to create a request with our query string
        QueryGQL query ->
            ( model
            , Http.send (\res -> GQLResponse res) (get model.gqlEndpoint query userDecoder)
            )

        -- upon success, add the decoded user to our model
        GQLResponse (Ok user) ->
            ( { model | user = user, error = "" }, Cmd.none )

        GQLResponse (Err err) ->
            ( { model | error = toString err }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        query =
            gql userQuery
    in
        div []
            [ div [] [ text (toString model) ]
            , div [] [ text (toString query) ]
              -- on click make a request using our query string
            , button [ onClick (QueryGQL query) ] [ text "Send GQL" ]
            ]
