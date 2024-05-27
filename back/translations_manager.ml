open! Base

type upload_req =
  { passage_id: string
  ; flow: Eio.Flow.source_ty Eio.Resource.t }

type declare_passage_res =
  | NotAllowed
  | Ok of string

let declare_passage
    (ctx : Ctx.t)
    ~(passage_start : Address.t)
    ~(passage_end : Address.t) =
  if Gamification_engine.is_allowed ctx "declare_passage"
  then
    Ok
      (Bible_access.create_passage
         ctx
         ~address_start:passage_start
         ~address_end:passage_end )
  else NotAllowed

type upload_res =
  | NotAllowed
  | Ok

let upload (ctx : Ctx.t) (reqs : upload_req list) : upload_res =
  if Gamification_engine.is_allowed ctx "audio:upload"
  then (
    reqs
    |> List.map ~f:(fun req ->
           (* let passage_id = *)
           (*   Bible_access.create_passage *)
           (*     ctx *)
           (*     ~address_start:req.passage_start *)
           (*     ~address_end:req.passage_end *)
           (* in *)
           Audio_access.store
             ctx
             [{Audio_access.passage_id= req.passage_id; flow= req.flow}] )
    |> ignore ;
    Ok )
  else NotAllowed

type read_req =
  { book: Address.book
  ; chapter: int
  ; include_comments: bool }

type comment =
  { body: string
  ; author_name: string }

type verse =
  { text: string
  ; comments: comment list option }

type chapter =
  { title: string
  ; verses: verse list }

let read (_req : read_req) : chapter = failwith "not implemented yet"
