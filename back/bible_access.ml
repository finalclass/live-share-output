open Base

type t =
  { address: Address.t
  ; text: string }

type passage = t list

type find_req =
  | Address of Address.t
  | AddressRange of (Address.t * Address.t)
  | Chapter of
      { book: Address.book
      ; chapter: int }
  | Text of string

type find_res = {passages: passage list}

let of_yojson_record json : t =
  let open Yojson.Safe.Util in
  let id =
    json
    |> member "id"
    |> to_string
    |> String.chop_prefix ~prefix:"bible:"
    |> Option.value ~default:""
    |> Yojson.Safe.from_string
  in
  match id with
  | `List [`Int book; `Int chapter; `Int verse] ->
      let book = book |> Address.int_to_book in
      { text= json |> member "verse" |> to_string
      ; address= {book; chapter; verse} }
  | _ -> failwith "invalid id"

let find ~(ctx : Ctx.t) query =
  ( match query with
  | Address addr ->
      let addr = addr |> Address.to_list |> List.map ~f:(fun i -> `Int i) in
      ctx.sq
        {|SELECT * FROM type::thing("bible", $addr) LIMIT 1|}
        [("addr", `List addr)]
  | AddressRange (s, e) ->
      let start_book, start_chapter, start_verse =
        match s |> Address.to_list with
        | [a; b; c] ->
            (a |> Int.to_string, b |> Int.to_string, c |> Int.to_string)
        | _ -> failwith "impossible"
      in
      let end_book, end_chapter, end_verse =
        match e |> Address.to_list with
        | [a; b; c] ->
            (a |> Int.to_string, b |> Int.to_string, c |> Int.to_string)
        | _ -> failwith "impossible"
      in
      ctx.sq
        ( "SELECT * FROM bible:["
        ^ start_book
        ^ ","
        ^ start_chapter
        ^ ","
        ^ start_verse
        ^ "]..=["
        ^ end_book
        ^ ", "
        ^ end_chapter
        ^ ", "
        ^ end_verse
        ^ "]" )
        []
  | Chapter {book; chapter} ->
      let book = book |> Address.book_to_int |> Int.to_string in
      let next_chapter = chapter + 1 |> Int.to_string in
      let chapter = chapter |> Int.to_string in
      ctx.sq
        ( "SELECT * FROM bible:["
        ^ book
        ^ ","
        ^ chapter
        ^ "NONE]..["
        ^ book
        ^ ","
        ^ next_chapter
        ^ ",NONE]" )
        []
  | Text phrase ->
      ctx.sq
        {|SELECT * FROM bible WHERE verse @@ $phrase OR string::contains(verse, $phrase)|}
        [("phrase", `String phrase)] )
  |> List.map ~f:of_yojson_record

let create_passage
    (ctx : Ctx.t)
    ~(address_start : Address.t)
    ~(address_end : Address.t) =
  let address_start = address_start |> Address.to_bible_id in
  let address_end = address_end |> Address.to_bible_id in
  let open Yojson.Safe.Util in
  ctx.sq
    {| 
     BEGIN TRANSACTION;
     LET $passage = CREATE passage;
     RELATE $passage->starts_at->$address_start;
     RELATE $passage->ends_at->$address_end;
     
     RETURN $passage;
     COMMIT TRANSACTION;
    |}
    [ ("address_start", `String address_start)
    ; ("address_end", `String address_end) ]
  |> List.hd_exn
  |> member "id"
  |> to_string
  |> String.split ~on:':'
  |> function
  | _ :: id :: _ -> id
  | _ -> failwith "invalid response from db, id format invalid"
