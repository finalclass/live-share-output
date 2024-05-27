open Base

module Request : sig
  type t =
    { req: Http.Request.t
    ; body: Cohttp_eio.Body.t
    ; socket: Cohttp_eio.Server.conn
    ; params: (string, string) Hashtbl.t
    ; env: Eio_unix.Stdenv.base
    ; sw: Eio.Switch.t }

  val read_cookies : t -> (string, string) List.Assoc.t
end

module Response : sig
  type t = Http.Response.t * Cohttp_eio.Body.t

  val header : string -> string -> t -> t

  val status : Cohttp.Code.status_code -> t

  val send_text : string -> t -> t

  val send_html : string -> t -> t
end

type route_handler = Request.t -> Response.t

type t

module Body : sig
  type t = (string * string list) list

  val of_yojson :
    Yojson.Safe.t -> (t, string) Ppx_deriving_runtime.Result.result

  val to_yojson : t -> Yojson.Safe.t

  val parse_body : Request.t -> t

  val dump : t -> unit

  val has_key : t -> string -> bool

  val get_string : t -> string -> string

  val get_float : t -> string -> float
end

val init : unit -> t

val get : string -> route_handler -> t -> t

val post : string -> route_handler -> t -> t

val put : string -> route_handler -> t -> t

val delete : string -> route_handler -> t -> t

val listen :
  port:int ref -> env:Eio_unix.Stdenv.base -> sw:Eio.Switch.t -> t -> unit

val html : string -> Http.Response.t * Cohttp_eio.Body.t

val redirect : string -> Http.Response.t * Cohttp_eio.Body.t
