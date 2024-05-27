open Base

let serve_file (prefix : string) (ctx : Ctx.t) (req : Blossom.Request.t) =
  let path_param = Hashtbl.find req.params "path" |> Option.value ~default:"" in
  let p =
    Eio.Path.(Eio.Stdenv.cwd ctx.env / ("static/" ^ prefix) / path_param)
  in
  if Eio.Path.is_file p
  then
    let body = Eio.Path.load p in
    let mime = Magic_mime.lookup path_param in
    ( Http.Response.make
        ~headers:(Http.Header.of_list [("content-type", mime)])
        ~status:`OK
        ()
    , Cohttp_eio.Body.of_string body )
  else Common.not_found ()

let render (chapter : Back.TranslationsManager.chapter) =
  let open Tyxml.Html in
  Common.layout
    [ h2 ~a:[a_class ["font-bold"; "text-lg"; "m-2"]] [txt chapter.title]
    ; ul
        ~a:[a_class ["m-2"]]
        ( chapter.verses
        |> List.mapi ~f:(fun index (v : Back.TranslationsManager.verse) ->
               li [txt ((index |> Int.to_string) ^ " " ^ v.text)] ) ) ]

let routes ~(ctx : Ctx.t) (app : Blossom.t) =
  app
  |> Blossom.get "/static/:path" (fun req -> serve_file "/" ctx req)
  |> Blossom.get "/fontawesome/css/:path" (fun req ->
         serve_file "/fontawesome/css/" ctx req )
  |> Blossom.get "/fontawesome/webfonts/:path" (fun req ->
         serve_file "/fontawesome/webfonts/" ctx req )
  |> Blossom.get "/" (fun _req ->
         render
           { title= "Księga rodzaju, rozdział 1"
           ; verses=
               [ { text= "Na początku Bóg stworzył niebo i ziemię."
                 ; comments= None }
               ; { text=
                     "A ziemia była bezkształtna i pusta i ciemność była nad \
                      głębią, a Duch Boży unosił się nad wodami."
                 ; comments= None } ] }
         |> Common.serve_html )
  |> Blossom.get "/bible/passage/new" (fun req ->
         let open Tyxml.Html in
         Common.(layout [txt "new passage form"] |> serve_html) )
  |> Blossom.post "/audio/upload/:passage_id"
     @@ fun req ->
     let ctx = ctx |> Ctx.for_req req in
     let passage_id = Hashtbl.find_exn req.params "passage_id" in
     match
       Back.TranslationsManager.(upload ctx [{passage_id; flow= req.body}])
     with
     | NotAllowed -> Blossom.redirect "/login"
     | Ok -> Blossom.html "Done"
