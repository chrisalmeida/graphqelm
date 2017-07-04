module Main exposing (..)

import Html as Html exposing (div, Html, text, button, h1, h3, h2, input, label)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (value)
import Json.Decode exposing (Decoder, at, map2, field, string)
import GraphQElm exposing (Query, gql, get, mutate)
import Http
import Examples.Css exposing (..)


type Msg
    = QueryGQL String
    | MutateGQL String
    | GQLResponse (Result Http.Error User)
    | UpdateEmail String
    | UpdateName String
    | UpdateView View


type View
    = Query
    | Mutate


type alias User =
    { name : String, email : String }


type alias Form =
    { name : String
    , email : String
    }


type alias Model =
    { user : User
    , error : String
    , gqlEndpoint : String
    , form : Form
    , view : View
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
    , form = { email = "", name = "" }
    , view = Query
    }



-- create a query record to find a user by email


userQuery : String -> Query
userQuery email =
    { resource = "user"
    , fields = [ "email", "name" ]
    , args = [ ( "email", email ) ]
    , alias = ""
    }



-- create a query record to create a user with email and name


userMutation : Form -> Query
userMutation { email, name } =
    { resource = "user"
    , fields = [ "email", "name" ]
    , args = [ ( "email", email ), ( "name", name ) ]
    , alias = ""
    }


userDecoder : Decoder User
userDecoder =
    at [ "data", "user" ]
        (map2 User (field "name" string) (field "email" string))


update : Msg -> Model -> ( Model, Cmd Msg )
update m model =
    case m of
        -- use get to create a request with our query
        QueryGQL query ->
            ( model
            , Http.send (\res -> GQLResponse res) (get model.gqlEndpoint query userDecoder)
            )

        -- use mutate to create a request with our mutation
        MutateGQL mutation ->
            ( model
            , Http.send (\res -> GQLResponse res) (mutate model.gqlEndpoint mutation userDecoder)
            )

        GQLResponse (Ok user) ->
            ( { model | user = user, error = "" }, Cmd.none )

        GQLResponse (Err err) ->
            ( { model | error = toString err }, Cmd.none )

        UpdateEmail email ->
            let
                u =
                    model.form

                newModel =
                    { model | form = { u | email = email } }
            in
                ( newModel, Cmd.none )

        UpdateName name ->
            let
                u =
                    model.form

                newModel =
                    { model | form = { u | name = name } }
            in
                ( newModel, Cmd.none )

        UpdateView view ->
            ( { model | view = view, error = "", form = { name = "", email = "" } }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        -- convert our queries to query strings
        query =
            gql (userQuery model.form.email)

        mutationQuery =
            gql (userMutation model.form)
    in
        case model.view of
            Query ->
                baseView model query (queryView model query)

            _ ->
                baseView model mutationQuery (mutateView model mutationQuery)


baseView : Model -> String -> Html Msg -> Html Msg
baseView model queryString childView =
    div []
        [ div [ navCSS ] [ h1 [] [ text "GraphQElm" ] ]
        , div
            [ containerCSS ]
            [ modelViewer model
            , h3 [] [ text ("GraphQElm " ++ (toString model.view) ++ ":") ]
            , text queryString
            , childView
            ]
        ]


queryView : Model -> String -> Html Msg
queryView model queryString =
    div []
        [ h2 [] [ text "Query" ]
        , queryUserForm model queryString
        , button [ buttonCSS "green", onClick (UpdateView Mutate) ] [ text "Use a Mutation" ]
        ]


mutateView : Model -> String -> Html Msg
mutateView model mutation =
    div []
        [ h2 [] [ text "Mutate" ]
        , createUserForm model mutation
        , button [ buttonCSS "blue", onClick (UpdateView Query) ] [ text "Use a Query" ]
        ]


modelViewer : Model -> Html Msg
modelViewer model =
    div []
        [ h3 [] [ text "Model:" ]
        , text (toString model)
        ]


createUserForm : Model -> String -> Html Msg
createUserForm model mutationQuery =
    let
        fields =
            [ ( "Email Address", UpdateEmail, model.form.email ), ( "Name", UpdateName, model.form.name ) ]

        formGroups =
            (List.map
                (\( field, trigger, val ) ->
                    div [ formGroupCSS ]
                        [ label [ value val ] [ text field ]
                        , input [ formInputCSS, onInput trigger ] []
                        ]
                )
                fields
            )
    in
        -- on click send our mutation to update
        div [ formCSS ] (List.append formGroups [ button [ buttonCSS "green", onClick (MutateGQL mutationQuery) ] [ text "Create" ] ])


queryUserForm : Model -> String -> Html Msg
queryUserForm model query =
    div [ formCSS ]
        [ div [ formGroupCSS ]
            [ label [] [ text "Email Address:" ]
            , input [ value model.form.email, formInputCSS, onInput UpdateEmail ] []
            , button
                -- on click send our query to update
                [ buttonCSS "blue", onClick (QueryGQL query) ]
                [ text "Find" ]
            ]
        ]
