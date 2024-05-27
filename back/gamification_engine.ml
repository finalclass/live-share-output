let secret_key = Sys.getenv "SECRET_KEY"

let is_allowed (ctx : Ctx.t) (resource : string) =
  if not (String.equal ctx.session_id secret_key)
  then false
  else
    match resource with
    | "audio:upload" -> true
    | _ -> false
