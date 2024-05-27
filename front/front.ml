open Base

let start () =
  Eio_main.run
  @@ fun env ->
  Eio.Switch.run
  @@ fun sw ->
  let ctx : Ctx.t =
    { env
    ; session_id= ""
    ; sq=
        Surrealdb.factory
          ~env
          ~sw
          { ns= "tl"
          ; db= "tl"
          ; url= "http://0.0.0.0:8920"
          ; user= "root"
          ; pass= "pass" } }
  in
  let port_ref = ref 8077 in
  Blossom.init ()
  |> Reader.routes ~ctx
  |> Blossom.listen ~port:port_ref ~env:ctx.env ~sw
