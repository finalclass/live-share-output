open Base
open Cohttp_eio

module Request = struct
  type t =
    { req: Http.Request.t
    ; body: Cohttp_eio.Body.t
    ; socket: Server.conn
    ; params: (string, string) Hashtbl.t
    ; env: Eio_unix.Stdenv.base
    ; sw: Eio.Switch.t }

  let read_cookies (req : t) : (string, string) List.Assoc.t =
    req.req
    |> Http.Request.headers
    |> (fun h -> Http.Header.get h "cookie")
    |> Option.value ~default:""
    |> String.split ~on:';'
    |> List.filter ~f:(fun s -> String.contains s '=')
    |> List.map ~f:(fun s -> String.strip s)
    |> List.map ~f:(fun s -> String.split s ~on:'=')
    |> List.map ~f:(fun l -> (List.hd_exn l, List.nth_exn l 1))
end

module Response = struct
  type t = Http.Response.t * Cohttp_eio.Body.t

  let status status =
    (Http.Response.make ~status (), Cohttp_eio.Body.of_string "")

  let header key value ((resp, body) : t) =
    ({resp with headers= Http.Header.add resp.headers key value}, body)

  let send_text (text : string) ((resp, _) : t) : t =
    ( { resp with
        headers= Http.Header.add resp.headers "content-type" "text/plain" }
    , Cohttp_eio.Body.of_string text )

  let send_html (text : string) ((resp, _) : t) : t =
    ( { resp with
        headers= Http.Header.add resp.headers "content-type" "text/html" }
    , Cohttp_eio.Body.of_string text )
end

type route_handler = Request.t -> Response.t

module Body = struct
  type t = (string * string list) list [@@deriving yojson]

  let parse_body (req : Request.t) =
    req.body |> Eio.Flow.read_all |> Uri.query_of_encoded

  let get_string (body : t) (key : string) : string =
    match List.Assoc.find body key ~equal:(fun a b -> String.equal a b) with
    | None -> ""
    | Some x -> x |> List.hd |> Option.value ~default:""

  let has_key (body : t) (key : string) : bool =
    List.Assoc.mem body key ~equal:(fun a b -> String.equal a b)

  let dump (body : t) =
    let str =
      body |> to_yojson |> Yojson.Safe.to_string |> Yojson.Safe.prettify
    in
    Stdlib.print_endline @@ "BODY: " ^ str

  let get_float (body : t) (key : string) : float =
    match get_string body key |> Float.of_string_opt with
    | None -> 0.0
    | Some x -> x
end

module Part = struct
  type t =
    | Static of string
    | Dynamic of string
end

module Route = struct
  type t =
    { meth: Http.Method.t
    ; handler: route_handler
    ; path_split: Part.t list }

  let build_path_split (path : string) : Part.t list =
    String.split path ~on:'/'
    |> List.map ~f:(fun (part : string) ->
           if String.length part > 0 && Char.equal (String.get part 0) ':'
           then
             Part.Dynamic (String.sub part ~pos:1 ~len:(String.length part - 1))
           else Part.Static part )

  let build (meth : Http.Method.t) (path : string) (handler : route_handler) : t
      =
    {meth; handler; path_split= build_path_split path}

  let is_matching (meth : Http.Method.t) (path : string) (route : t) : bool =
    let split = String.split path ~on:'/' in
    if not Http.Method.(String.equal (to_string meth) (to_string route.meth))
    then false
    else
      let all_matching =
        List.for_all2 split route.path_split ~f:(fun string_part route_part ->
            match route_part with
            | Part.Static s -> String.equal s string_part
            | Part.Dynamic _ -> true )
      in
      match all_matching with
      | Ok b -> b
      | Unequal_lengths -> false

  let to_args (r : t) (path : string) : (string, string) Hashtbl.t =
    let split = String.split path ~on:'/' in
    let args : (string, string) Hashtbl.t =
      Hashtbl.create ~growth_allowed:true ~size:0 (module String)
    in
    let _ =
      List.fold2
        split
        r.path_split
        ~init:args
        ~f:(fun acc string_part route_part ->
          match route_part with
          | Part.Static _ -> acc
          | Part.Dynamic s ->
              let () = Hashtbl.add_exn acc ~key:s ~data:string_part in
              acc )
    in
    args
end

type t = {routes: Route.t list}

let init () : t = {routes= []}

let html (body : string) : Http.Response.t * Cohttp_eio.Body.t =
  ( Http.Response.make
      ~status:`OK
      ~headers:(Http.Header.of_list [("content-type", "text/html")])
      ()
  , Cohttp_eio.Body.of_string body )

let redirect (location : string) : Http.Response.t * Cohttp_eio.Body.t =
  ( Http.Response.make
      ~status:`Found
      ~headers:(Http.Header.of_list [("location", location)])
      ()
  , Cohttp_eio.Body.of_string "" )

let make_verb verb path handler app =
  let meth = Http.Method.of_string (verb |> String.uppercase) in
  let new_route : Route.t = Route.build meth path handler in
  {routes= new_route :: app.routes}

let get = make_verb "get"

let post = make_verb "post"

let put = make_verb "put"

let delete = make_verb "delete"

let handler ~app ~env ~sw socket request body =
  let resource = Http.Request.resource request in
  let meth = Http.Request.meth request in
  let found =
    app.routes
    |> List.find ~f:(fun (r : Route.t) -> Route.is_matching meth resource r)
  in
  match found with
  | None ->
      ( Http.Response.make ~status:`Not_found ()
      , Cohttp_eio.Body.of_string "Not found" )
  | Some (r : Route.t) ->
      r.handler
        {body; req= request; socket; params= Route.to_args r resource; env; sw}

let listen
    ~(port : int ref)
    ~(env : Eio_unix.Stdenv.base)
    ~(sw : Eio.Switch.t)
    (app : t) : unit =
  let socket =
    Eio.Net.listen
      env#net
      ~sw
      ~backlog:128
      ~reuse_addr:true
      (`Tcp (Eio.Net.Ipaddr.V4.loopback, !port))
  and server =
    Cohttp_eio.Server.make
      ~callback:(fun s r b -> handler ~app ~env ~sw s r b)
      ()
  in
  Stdlib.print_endline
    ("Starting server http://localhost:" ^ Int.to_string !port) ;
  Cohttp_eio.Server.run socket server ~on_error:raise
