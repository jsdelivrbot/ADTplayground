Folders
- `purescript_autocomplete`
  - demo: `dist/index.html`
  - design process: `StatebackPrototype/architecture/autocomplete`
  - accept selection by both keyboard and mouse 
  - mouse selection is prioritized, which means that mouse selection will be display in the input field when keyboard selection is also available
    - TODO: configurable behaviors
  - when keyboard cursor at the upper/lower boundary, further up/down keypress will push the window sliding to the correct position so keyboard cursor is always in the view
    - will lock in the correct place even when the current scroll position is not precisely align with any of the items' boundaries
  - In demo page, data will get refreshed 10 seconds after the page being loaded to demonstrate correct behavior upon reset
  - TODO: add debouncer to input field (`purescript_debouncer`)
- `purescript_auto_size_input`
  - demo: `dist/index.html`
  - automatically adjust the width of the input box to fit its current input text
  - `Enter` for confirmation to add an item
  - click on `X` to remove an item
  - This will be integrated into `prescript_autocomplete`
- `purescript-pseudo-random_enhance`
  - built on top of `purescript-pseudo-random`
  - `randomsWithSeed` and `randomRsWithSeed` return randomly generated values with the final seed which can later be feed into another random generation
  - an example using State monad to compose seed-dependent computations
- `elm_register_form`
  - demo: `demo/`
    - `yarn install`
    - `yarn start`, page is available at `localhost:3000`.
  - composable validators built on applicative functors (`elm_src/Validation.elm`)
    - email
      - non-empty (`isNotEmpty`)
      - decided by a dedicated regular expression (`isEmail`)
    - password
      - non-empty (`isNotEmpty`)
      - constraint on length (`>= 6`)
    - repeated password
      - non-empty (`isNotEmpty`)
      - identical to password (`isEqualTo`)
    - age
      - optional (augment a `Validator` by `optional`)
        -  `optional :: Validator String a -> Validator String (Maybe a)`
      - natural number (`isNatural`)
    - policy
      - checked (`isTrue`)
  - validations will be triggered by each key stroke after the first attempt
- `js_class_projects`
  - `cyclejs_google_map`
    - demo: `demo/`
      - `yarn install`
      - `yarn start`, page is available at `localhost:8081`.
    - This was originally built on top of a elasticsearch index with a geo distance query.
    - debouncing is implemented using `xstream`
  - `async_fluture_db_cli`, see README
  - `elastic_search`, queries for ES
  - `neo4j`, queries for Neo4j
  - `ramda_scrapper_fandango`, scrapper powered by `axios`, `cheerio` and `Ramda`
  - `ramda_api_TMS`, transform data from TMS api
- `js_data_structures`, implementation of some basic constructs from FP in JS
- `elm_logic_functions`, `elm_monoid`, `elm_helpers`, utility functions for Elm
- `purescript_coroutines`, digging internals of `purescript-coroutines`
- `crocks_async_error_handling`, usage of `Async` monad in CrocksJS
- `crocks_monoid_first_match`, usage of `First` monoid in CrocksJS
- `crocks_async_with_readers`, usage of `Reader` monad to inject environment
- `crocks_binary_branching`, 6 ways of branching and integration by function composition
  - `pic/`, draft
    
