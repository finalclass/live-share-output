let make_ctx (fn : Ctx.t -> 'a) : 'a =
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
          ; db= "test"
          ; url= "http://0.0.0.0:8920"
          ; user= "root"
          ; pass= "pass" } }
  in
  ctx.sq "USE DB test;" [] |> ignore ;
  let result = fn ctx in
  ctx.sq "REMOVE DB test" [] |> ignore ;
  result
