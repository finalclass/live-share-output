open Base

type t =
  { env: Eio_unix.Stdenv.base
  ; session_id: string
  ; sq: Surrealdb.sq }

let read_session_id_from_req req =
  let cookies = Blossom.Request.read_cookies req in
  List.Assoc.find cookies ~equal:String.equal "session_id"
  |> Option.value ~default:""

let for_req req ctx = {ctx with session_id= read_session_id_from_req req}
