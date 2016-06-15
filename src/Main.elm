import Html exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task

-- TYPES

-- MAIN
main = Html.program
    { init = init "http://httpbin.org/ip" ""
    --{ init = init "http://jsonplaceholder.typicode.com/" ""
    --{ init = init "http://www.thomas-bayer.com/sqlrest" ""
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
    { start_url   : String
    , current_url : String
    , data        : String
    }

type Msg
    = Reset
    | FetchSucceed String
    | FetchFail Http.Error

-- INIT

init : String -> String -> (Model, Cmd Msg)
init start_url current_url =
    ( Model start_url current_url ""
    , Cmd.none
    )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MY STUFF
fetch_url : String -> Cmd Msg
fetch_url url =
    Task.perform FetchFail FetchSucceed (Http.get decodeUrl url)

decodeUrl : Json.Decoder String
decodeUrl =
    Json.at ["origin"] Json.string

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Reset ->
            (model, fetch_url model.start_url)

        FetchSucceed data ->
            ( { model | data = data }, Cmd.none )

        FetchFail _ ->
            ( { model | data = "FAILED" }, Cmd.none )

-- VIEW

view : Model -> Html Msg
view model =
    span []
        [ div [] [ text (toString model.start_url) ]
        , div [] [ text (toString model.current_url) ]
        , div [] [ text (toString model.data) ]
        , div [] [ button [ onClick Reset ] [ text "Reset" ] ]
        ]
