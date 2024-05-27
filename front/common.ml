let serve_html html =
  let s = Stdlib.Format.asprintf "%a" (Tyxml.Html.pp ()) html in
  Blossom.html s

let serve_html_elt elt =
  let s = Stdlib.Format.asprintf "%a" (Tyxml.Html.pp_elt ()) elt in
  Blossom.html s

let not_found () =
  ( Http.Response.make ~status:`Not_found ()
  , Cohttp_eio.Body.of_string "not found" )

(* <i class="fa-solid fa-user"></i> *)
let icon ?(regular : bool option) (name : string) =
  let open Tyxml.Html in
  i
    ~a:
      [ a_class
          [ ( if regular |> Option.value ~default:false
              then "fa-regular"
              else "fa-solid" )
          ; "fa-" ^ name ] ]
    []

let render_avatar () =
  let open Tyxml.Html in
  div
    ~a:
      [ a_class
          [ "bg-slate-700"
          ; "px-2"
          ; "text-center"
          ; "text-slate-300"
          ; "py-1"
          ; "text-sm"
          ; "rounded-full"
          ; "border-2"
          ; "border-slate-500" ] ]
    [txt "JK"]

let player_button ?a icon_name =
  let a_attr = a in
  let open Tyxml.Html in
  button
    ~a:
      ( [ a_class
            [ "bg-slate-700"
            ; "text-slate-400"
            ; "py-1"
            ; "px-3"
            ; "hover:bg-slate-500"
            ; "rounded-xl" ] ]
      @ (a_attr |> Option.value ~default:[]) )
    [icon icon_name]

let render_search () =
  let open Tyxml.Html in
  form
    ~a:[a_class ["flex"; "items-center"]]
    [ input
        ~a:
          [ a_input_type `Search
          ; a_class
              [ "outline-none"
              ; "placeholder-text-slate-400"
              ; "text-white"
              ; "px-4"
              ; "py-1"
              ; "rounded-xl"
              ; "bg-slate-800"
              ; "ring-slate-700" ]
          ; a_placeholder "szukaj..." ]
        ()
    ; button
        ~a:
          [ a_class
              [ "bg-slate-700"
              ; "text-slate-400"
              ; "py-1"
              ; "px-3"
              ; "hover:bg-slate-500"
              ; "rounded-xl" ] ]
        [icon "search"] ]

let render_player () =
  let open Tyxml.Html in
  div
    ~a:[a_class ["flex"; "gap-1"]]
    [ player_button "angles-left"
    ; player_button "angles-right"
    ; progress
        ~a:
          [ a_class
              [ "my-2"
              ; "[&::-webkit-progress-value]:bg-blue-400"
              ; "[&::-webkit-progress-bar]:bg-zinc-200" ]
          ; a_max 100.0
          ; a_float_value 32.0 ]
        [txt "abc"]
    ; div ~a:[a_class ["flex"; "items-center"]] [span [txt "12s / 58s"]]
    ; player_button "play"
    ; player_button "arrows-rotate" ]

let logo () =
  let open Tyxml.Html in
  h1
    [ a
        ~a:[a_href "/"; a_title "Theos Logos"]
        [ img
            ~alt:"Theos Logos logo"
            ~src:"/static/logoTXT.png"
            ~a:[a_class ["w-8"]]
            () ] ]

let layout content =
  let open Tyxml.Html in
  html
    (head
       (title (txt "Theos Logos"))
       [ meta ~a:[a_charset "UTF-8"] ()
         (* <link href="/your-path-to-fontawesome/css/fontawesome.css" rel="stylesheet" /> *)
       ; meta
           ~a:
             [a_name "viewport"; a_content "width=device-width, initial-scale=1"]
           ()
       ; meta
           ~a:
             [ a_name "description"
             ; a_content "Biblia audio jakiej jeszcze nie słyszałeś" ]
           ()
       ; link ~rel:[`Stylesheet] ~href:"/fontawesome/css/fontawesome.css" ()
       ; link ~rel:[`Stylesheet] ~href:"/fontawesome/css/solid.css" ()
       ; link ~rel:[`Stylesheet] ~href:"/fontawesome/css/regular.css" ()
       ; link ~rel:[`Stylesheet] ~href:"/static/style.css" ()
       ; link ~rel:[`Icon] ~href:"/static/favicon.ico" ()
       ; script ~a:[a_src "/static/htmx-1.9.12.min.js"] (txt "") ] )
    (body
       ~a:[a_class ["bg-slate-900"; "text-slate-400"; "font-inter"]]
       [ nav
           ~a:
             [ a_class
                 [ "sticky"
                 ; "top-0"
                 ; "z-50"
                 ; "bg-slate-900/95"
                 ; "shadow-md"
                 ; "shadow-slate-900/5"
                 ; "[@supports(backdrop-filter:blur(0))]:bg-slate-900/75"
                 ; "backdrop-blur"
                 ; "py-5"
                 ; "px-3"
                 ; "flex"
                 ; "gap-3"
                 ; "items-center"
                 ; "justify-between" ] ]
           [ div
               ~a:[a_class ["flex"; "gap-3"; "items-center"]]
               [ logo ()
               ; button
                   ~a:
                     [ a_class
                         [ "bg-slate-700"
                         ; "text-slate-400"
                         ; "px-5"
                         ; "py-1"
                         ; "rounded"
                         ; "hover:bg-slate-500" ] ]
                   [txt "Rdz"]
               ; render_player () ]
           ; div
               ~a:[a_class ["flex"; "gap-3"; "items-center"]]
               [render_search (); player_button "question"; render_avatar ()] ]
       ; main content ] )
