module Contact exposing (..)

import Html
    exposing
        ( button
        , div
        , h1
        , input
        , label
        , text
        , textarea
        , Html
        )
import Html.Attributes
    exposing
        ( id
        , class
        , disabled
        , placeholder
        , required
        , rows
        , type_
        , value
        , novalidate
        )
import Html.Events
    exposing
        ( onClick
        , onInput
        , onSubmit
        )
import Http
    exposing
        ( expectStringResponse
          -- jsonBody : a -> Http.Body
        , jsonBody
          -- post : String -> Http.Body -> Json.Decoder.Decoder a -> Http.Request a
          -- post url
        , post
          {-
             request :
             { method : String
             , headers : List Header
             , url : String
             , body : Body
             , expect : Expect a
             , timeout : Maybe Time
             , withCredentials : Bool
             } -> Request a
          -}
        , request
          -- send : (Result Error a -> msg) -> Request a -> Cmd msg
        , send
          {-
             type Error
                 = BadUrl String
                 | Timeout
                 | NetworkError
                 | BadStatus (Response String)
                 | BadPayload String (Response String)
          -}
        , Error
        )
import Json.Encode as Encode
import Validation
    exposing
        ( customizeErr
        , displayValue
        , extractError
        , isNotEmpty
        , isEmail
        , isInt
        , isNatural
        , validate
        , (>=>)
        , (<*>)
        , pure
        , Field
            ( NotValidated
            , Valid
            , Invalid
            )
        , OptionalField
        )


type alias Email =
    String


type alias Message =
    String


type alias Age =
    Int


type alias ErrMsg =
    String


type alias Model =
    { email : Field Email
    , message : Field Message
    , age : OptionalField Age
    , status : SubmissionStatus
    }


type SubmissionStatus
    = NotSubmitted
    | InProcess
    | Succeeded
    | Failed


initialModel : Model
initialModel =
    { email = NotValidated ""
    , message = NotValidated ""
    , age = NotValidated ""
    , status = NotSubmitted
    }


type Msg
    = InputEmail Email
    | InputMessage Message
    | InputAge String
    | Submit
    | SubmitResponse (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputEmail email_ ->
            ( { model | email = NotValidated <| String.toLower email_ }, Cmd.none )

        InputMessage message_ ->
            ( { model | message = NotValidated message_ }, Cmd.none )

        InputAge age_ ->
            ( { model | age = NotValidated age_ }, Cmd.none )

        Submit ->
            model |> validateModel |> submitIfValid

        SubmitResponse res ->
            case res of
                Result.Ok () ->
                    ( { model
                        | status = Succeeded
                        , email = NotValidated ""
                        , message = NotValidated ""
                        , age = NotValidated ""
                      }
                    , Cmd.none
                    )

                Result.Err _ ->
                    ( { model | status = Failed }, Cmd.none )


validateModel : Model -> Model
validateModel model =
    let
        -- customize error messages
        emailValidation =
            customizeErr "An email is required" isNotEmpty
                >=> customizeErr "Please ensure this is a valid email" isEmail

        messageValidation =
            customizeErr "A message is required" isNotEmpty
    in
        { model
          -- | email = model.email |> validate (isNotEmpty >=> isEmail)
            | email = model.email |> validate emailValidation

            -- , message = model.message |> validate isNotEmpty
            , message = model.message |> validate messageValidation
            , age = model.age |> validate (Validation.optional isNatural)
        }


submitIfValid : Model -> ( Model, Cmd Msg )
submitIfValid model =
    let
        submissionResult : Field (Cmd Msg)
        submissionResult =
            -- Validation.pure submit
            --     |> Validation.apply model.email
            --     |> Validation.apply model.message
            --     |> Validation.apply model.age
            (Validation.pure submit)
                <*> model.email
                <*> model.message
                <*> model.age
    in
        case submissionResult of
            Valid cmd ->
                ( { model | status = InProcess }, cmd )

            _ ->
                ( model, Cmd.none )


submit : Email -> Message -> Maybe Age -> Cmd Msg
submit email message age =
    let
        url =
            "http://localhost:3000/api/contact"

        json =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "message", Encode.string message )
                , ( "age"
                  , age
                        |> Maybe.map Encode.int
                        |> Maybe.withDefault Encode.null
                  )
                ]

        -- 1. lazy solution: expecting JSON and transform it into ().
        -- for POST request, usually no return is expected but a Status code.
        -- a success POST with no return is denoted as Unit / ().
        -- decoder : Decode.Decoder ()
        -- decoder =
        --     -- Basics.always : a -> b -> a,
        --     -- create a function that always returns the same value.
        --     Decode.map (always ()) <| Decode.string
        -- request : Http.Request ()
        -- request =
        --     Http.post url (Http.jsonBody json) decoder
        -- 2. better solution
        request : Http.Request ()
        request =
            Http.request
                { method = "POST"
                , headers = []
                , url = url
                , body = Http.jsonBody json
                , expect = Http.expectStringResponse (\_ -> Result.Ok ())
                , timeout = Maybe.Nothing
                , withCredentials = False
                }
    in
        Http.send SubmitResponse request


view : Model -> Html Msg
view model =
    let
        header model =
            div []
                [ h1 [] [ text "Contact us" ]
                , renderStatus model.status
                ]

        renderStatus status =
            case status of
                NotSubmitted ->
                    div [] []

                InProcess ->
                    div [] [ text "Sending request..." ]

                Succeeded ->
                    div [] [ text "Request received" ]

                Failed ->
                    div [] [ text "Request failed. Please try again." ]

        errorLabel : Field a -> Html msg
        errorLabel field =
            label
                [ class "label label-error" ]
                [ field
                    |> extractError
                    |> Maybe.withDefault ""
                    |> text
                ]

        body =
            div []
                [ div []
                    [ input
                        [ placeholder "your email *"

                        -- utilize browser's built-in validation,
                        -- by specifying the type to `email`
                        , type_ "email"
                        , onInput InputEmail
                        , value <| displayValue identity model.email
                        , required True
                        ]
                        []
                    , errorLabel model.email
                    ]
                , div []
                    [ textarea
                        [ placeholder "your message *"
                        , rows 7
                        , onInput InputMessage
                        , value <| displayValue identity model.message
                        , required True
                        ]
                        []
                    , errorLabel model.message
                    ]
                , div []
                    [ textarea
                        [ placeholder "your age"
                        , onInput InputAge
                        , value <|
                            displayValue
                                (Maybe.withDefault "" << Maybe.map toString)
                            <|
                                model.age
                        ]
                        []
                    , errorLabel model.age
                    ]
                ]

        footer model =
            div []
                [ -- default behavior of any button attached to a form is to refresh the page
                  button
                    [ -- onClick Submit
                      disabled (model.status == InProcess)
                    ]
                    [ text "Submit" ]
                , button
                    [ -- default type: `submit`
                      -- rewrite the type to normal `button`
                      type_ "button"
                    ]
                    [ text "Cancel" ]
                ]
    in
        Html.form
            [ -- default button type in form is `submit`
              -- rewrite the default behavior of `submit` button which is to refresh the page
              onSubmit Submit

            -- Prevent browser's built-in field validation functionality
            , Html.Attributes.novalidate True
            ]
            [ header model
            , body
            , footer model
            , div [] [ text <| toString <| model ]
            ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = \model -> Sub.none
        , view = view
        }
