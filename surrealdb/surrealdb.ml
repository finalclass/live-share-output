open Base

module type Client = sig
  val get : string -> Http.Response.t * Cohttp_eio.Body.t

  val post :
       string
    -> string
    -> ?headers:Http.Header.t
    -> unit
    -> Http.Response.t * Cohttp_eio.Body.t
end

type opts =
  { ns: string
  ; db: string
  ; url: string
  ; user: string
  ; pass: string }

type t =
  { opts: opts
  ; client: (module Client) }

type query_error =
  { code: int
  ; details: string
  ; description: string
  ; information: string }

type sq = string -> (string, Yojson.Safe.t) List.Assoc.t -> Yojson.Safe.t list

let sq_to_yojson _sq = `String "sq"

let build_client
    ~(url : string)
    ~(env : Eio_unix.Stdenv.base)
    ~(sw : Eio.Switch.t) : (module Client) =
  let client = Cohttp_eio.Client.make ~https:None env#net in
  ( module struct
    let get path = Cohttp_eio.Client.get ~sw client (Uri.of_string (url ^ path))

    let post path body ?(headers = Http.Header.of_list []) () =
      let body = Cohttp_eio.Body.of_string body in
      Cohttp_eio.Client.post
        ~headers
        ~sw
        ~body
        client
        (Uri.of_string (url ^ path))
  end : Client )

let is_response_ok json =
  match json with
  | `List _ -> true
  | _ -> false

let translate_response (json : Yojson.Safe.t) : Yojson.Safe.t list =
  let open Yojson.Safe.Util in
  if is_response_ok json
  then
    match json |> to_list |> List.hd with
    | None -> failwith "Empty response"
    | Some json -> (
        let result = json |> member "result" in
        match result with
        | `List l -> l
        | `String s ->
            Stdlib.print_endline @@ "RESULT: " ^ s ;
            []
        | `Null -> []
        | _ ->
            failwith
            @@ "Error response from DB: "
            ^ Yojson.Safe.pretty_to_string json )
  else
    failwith @@ "Error response from DB: " ^ Yojson.Safe.pretty_to_string json

let query (conn : t) (sql : string) (vars : (string, Yojson.Safe.t) List.Assoc.t)
    =
  let query =
    vars
    |> List.map ~f:(fun (k, v) -> (k, [v |> Yojson.Safe.to_string]))
    |> Uri.encoded_of_query
  in
  let module Client = (val conn.client) in
  let r =
    Client.post
      ~headers:
        (Http.Header.of_list
           [ ( "Authorization"
             , "Basic "
               ^ Base64.encode_exn (conn.opts.user ^ ":" ^ conn.opts.pass) )
           ; ("Accept", "application/json")
           ; ("NS", conn.opts.ns)
           ; ("DB", conn.opts.db) ] )
      ("/sql?" ^ query)
      sql
      ()
  in
  let body = snd r in
  let body_str =
    Eio.Buf_read.(parse_exn take_all) body ~max_size:Int.max_value
  in
  let json = Yojson.Safe.from_string body_str in
  translate_response json

let factory (opts : opts) ~(env : Eio_unix.Stdenv.base) ~(sw : Eio.Switch.t) :
    sq =
  let client = build_client ~url:opts.url ~env ~sw in
  let conn = {opts; client} in
  query conn
