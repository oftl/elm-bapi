import Html exposing (..)
import Html.App as Html
import Html.Events exposing (onClick)
import Http
import Http.Decorators
import Json.Decode as Json
import Task

-- TYPES

-- deck of cards        http://deckofcardsapi.com
-- ron swanson quotes   http://ron-swanson-quotes.herokuapp.com/v2/quotes
-- discogs              https://api.discogs.com
-- football data        http://api.football-data.org/v1/soccerseasons
-- star wars            http://swapi.co/api/?format=json

-- MAIN
main = Html.program
    -- ok, serve application/json
    -- { init = init "http://swapi.co/api/?format=json" ""
    -- { init = init "http://jsonplaceholder.typicode.com/posts/1" ""

    -- not ok, serves text/html
    { init = init "http://deckofcardsapi.com" ""

    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
    { start_url   : String
    , current_url : String
    , data        : String
    , last_error  : String
    , last_status : String
    }

type Msg
    = Reset
    | FetchSucceed Http.Response
    | FetchFail Http.Error

-- INIT

init : String -> String -> (Model, Cmd Msg)
init start_url current_url =
    ( Model start_url current_url "" "" ""
    , Cmd.none
    )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MY STUFF

-- TODO: must set current_url; must have model for that though!
fetch_url : String -> Cmd Msg
fetch_url url =
    let
        -- settings = defaultSettings
        settings =
            { timeout = 0
            , onStart = Nothing
            , onProgress = Nothing
            , desiredResponseType = Just "application/json"
            , withCredentials = False
            }
        request =
            { verb    = "GET"
            , headers = []
            , url     = url
            , body    = Http.empty
            }
    in
        -- getString : String -> Task Error String
        -- get : Decoder value -> String -> Task Error value
        -- send : Settings -> Request -> Task RawError Response
        -- perform : (x -> msg) -> (a -> msg) -> Task x a -> Cmd msg

        --Task.perform FetchFail FetchSucceed (Http.send settings request)

        Task.perform FetchFail FetchSucceed (
            Http.Decorators.promoteError (Http.send settings request)
        )

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Reset ->
            (model, fetch_url model.start_url)

        FetchSucceed response ->
            ( { model
                | data = toString response.value
                , last_status = toString response.status ++ " (" ++ toString response.statusText ++ ")"
              }
            , Cmd.none
            )

        FetchFail raw_error ->
            let m = { model
                    | data = ""
                    , last_error = toString raw_error
                    }
            in (m, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
    span []
        [ div [] [ text ("start url: " ++ toString model.start_url) ]
        , div [] [ text ("current url: " ++ toString model.current_url) ]
        , div [] [ text ("data: " ++ toString model.data) ]
        , div [] [ text ("last error: " ++ toString model.last_error) ]
        , div [] [ text ("last status: " ++ toString model.last_status) ]
        , div [] [ button [ onClick Reset ] [ text "Reset" ] ]
        ]
