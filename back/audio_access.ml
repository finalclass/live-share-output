open Base

type store_req =
  { passage_id: string
  ; flow: Eio.Flow.source_ty Eio.Resource.t }

let store_one (ctx : Ctx.t) req =
  Eio.Switch.run
  @@ fun sw ->
  let ( / ) = Eio.Path.( / ) in
  let cwd = Eio.Stdenv.cwd ctx.env in
  let path = cwd / "uploads" / (req.passage_id ^ ".mp3") in
  let dest = Eio.Path.open_out ~create:(`If_missing 0o600) ~sw path in
  Eio.Flow.copy req.flow dest ;
  path

type query = ByPassages of string list

let find_one (ctx : Ctx.t) passage_id =
  let passage_id = passage_id |> String.filter ~f:(Char.equal '/') in
  let ( / ) = Eio.Path.( / ) in
  let cwd = Eio.Stdenv.cwd ctx.env in
  let path = cwd / "uploads" / (passage_id ^ ".mp3") in
  if Eio.Path.is_file path then Some path else None

let find (ctx : Ctx.t) = function
  | ByPassages passages_ids -> passages_ids |> List.map ~f:(find_one ctx)

let store (ctx : Ctx.t) (reqs : store_req list) =
  reqs |> List.map ~f:(store_one ctx)
