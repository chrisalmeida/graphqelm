module GraphQElm.Helpers exposing (..)


isInt : String -> Bool
isInt str =
    case String.toInt str of
        Ok int ->
            True

        _ ->
            False


appendQuery : String -> String -> String
appendQuery a b =
    a ++ "," ++ b
