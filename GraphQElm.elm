module GraphQElm exposing (gql, concatQueries, nest, get, mutate, concatGQLUrl, Query)

{-| GraphQElm exposes a simple Elm API for composing GraphQL queries and making requests to a GraphQL endpoint.

# Defining and Composing Queries
@docs Query, gql, concatQueries, nest

# Making Requests
@docs get, mutate, concatGQLUrl

-}

import GraphQElm.Helpers exposing (..)
import Json.Decode exposing (Decoder)
import Http exposing (get, post, Request, emptyBody)


{-| Query type used to define a GraphQElm query.

    import GraphQElm exposing (Query)

    query : Query
    query =
        {resource = "products"
        , fields = ["name", "price"]
        , args = []
        , alias = ""
        }
-}
type alias Query =
    { resource : String
    , fields : List String
    , args : List ( String, String )
    , alias : String
    }


{-| Converts a Query type into a GraphQL query.

    import GraphQElm exposing (Query, gql)

    query : Query
    query =
        {resource = "user"
        , fields = ["name", "age", "city"]
        , args = [("email", "steve@apple.com")]
        , alias = "steveJobs"
        }

    gql query == "steveJobs: users(email: "steve@apple.com"){name, age, city}"
-}
gql : Query -> String
gql query =
    parseQuery query


{-| Concatenates non-nested queries, allowing for multiple top-level queries.

    import GraphQElm exposing (Query, gql, concatQueries)

    usersQuery : Query
    usersQuery =
        {resource = "users"
        , fields = ["name", "age", "city"]
        , args = []
        , alias = ""
        }

    boardsQuery : Query
    boardsQuery =
        {resource = "boards"
        , fields = ["title", "created_at"]
        , args = []
        , alias = ""
        }

    concatQueries [(gql query1), (gql query2)] == "users{name, age, city}, boards{title, created_at}"
-}
concatQueries : List String -> String
concatQueries queries =
    let
        queryString =
            List.foldr
                (\query acc ->
                    (if not (String.contains query acc) then
                        (appendQuery query acc)
                     else
                        acc
                    )
                )
                ""
                queries

        q =
            if queryString |> String.endsWith "," then
                String.dropRight 1 queryString
            else
                queryString
    in
        q


{-| Used for nesting a query.

    import module GraphQElm exposing (Query, gql, nest)

    usersQuery : Query
    usersQuery =
        {resource = "users"
        , fields = ["name", "age", "city"]
        , args = []
        , alias = ""
        }

    boardsQuery : Query
    boardsQuery =
        {resource = "boards"
        , fields = ["title", "created_at"]
        , args = []
        , alias = ""
        }

    usersBoards =
        nest usersQuery boardsQuery

    usersBoards == "users{name, age, city, boards{title, created_at}}"

    -- another way to achieve nested queries would be to add (gql someQuery) to the Query fields list.

    usersQuery : Query
    usersQuery =
        {resource = "users"
        , fields = ["name", "age", "city", (gql boardsQuery)]
        , args = []
        , alias = ""
        }

    usersBoards =
        gql usersQuery
-}
nest : String -> String -> String
nest a b =
    let
        str =
            String.dropRight 1 a
    in
        str ++ "," ++ b ++ "}"


{-| Creates a "GET" request for a given query.

    ...

    userQuery : Query
    userQuery =
        {resource = "user"
        , fields = ["name", "email_address"]
        , args = []
        , alias = ""
        }


    view : Model -> Html Msg
    view model =
        div [onClick (QueryGQL (gql userQuery))] [button [] [text "Send Query"]]


    update : Msg -> Model -> ( Model, Cmd Msg )
    update m model =
        case m of
            QueryGQL query ->
                ( model, Http.send (\res -> GQLResponse res) (get model.serverBaseUrl query userDecoder) )
    ...
-}
get : String -> String -> Decoder a -> Http.Request a
get url query d =
    Http.get (url ++ "?query={" ++ query ++ "}") d


{-| Creates a "POST" request for a given query.

    ...

    createUser : Query
    createUser =
        {resource = "user"
        , fields = ["name", "email_address"]
        , args = [("name", "Chris"), ("email_address", "chris@example.com")]
        , alias = ""
        }


    view : Model -> Html Msg
    view model =
        div []
            [button [onClick (QueryGQL (gql createUser))] [text "Send Query"]
            ]


    update : Msg -> Model -> ( Model, Cmd Msg )
    update m model =
        case m of
            QueryGQL query ->
                ( model, Http.send (\res -> GQLResponse res) (mutate model.serverBaseUrl query userDecoder) )
    ...
-}
mutate : String -> String -> Decoder a -> Http.Request a
mutate url query d =
    Http.post (url ++ "?query=mutation{" ++ query ++ "}") Http.emptyBody d


{-| Concatenates a URL and query string.
Useful for custom Http requests as the url field.

    mutate : Bool
    mutate = False

    usersQuery : Query
    usersQuery =
        {resource = "users"
        , fields = ["name", "age"]
        , args = []
        , alias = ""}

    url = concatGQLUrl mutate "http://localhost:4000/graphql" (gql usersQuery)

    url == "http://localhost:4000/graphql?query={users{name, age}}"

-}
concatGQLUrl : Bool -> String -> String -> String
concatGQLUrl mutate url query =
    case mutate of
        False ->
            url ++ "?query={" ++ query ++ "}"

        True ->
            url ++ "?query=mutation{" ++ query ++ "}"



-- private


parseQuery : Query -> String
parseQuery query =
    let
        args =
            List.map
                (\i ->
                    let
                        ( arg, val ) =
                            i

                        valStr =
                            if isInt val then
                                val
                            else
                                "\"" ++ val ++ "\""
                    in
                        arg ++ ": " ++ valStr
                )
                query.args

        argsString =
            List.foldl (\i acc -> i ++ "," ++ acc) "" args
                |> String.dropRight 1

        finalString =
            if (String.length argsString) > 0 then
                "(" ++ argsString ++ ")"
            else
                ""

        aliasName =
            if String.length query.alias > 0 then
                query.alias ++ ": "
            else
                query.alias

        queryString =
            aliasName ++ query.resource ++ finalString ++ "{" ++ (String.join "," query.fields) ++ "}"
    in
        queryString
