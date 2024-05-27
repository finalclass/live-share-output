let find_ot_bible_hub_address address =
  let open Address in
  let book_str =
    match address.book with
    | Gen -> "genesis"
    | Ex -> "exodus"
    | Lev -> "leviticus"
    | Num -> "numbers"
    | Deut -> "deuteronomy"
    | Josh -> "joshua"
    | Judg -> "judges"
    | Ruth -> "ruth"
    | Sam1 -> "1_samuel"
    | Sam2 -> "2_samuel"
    | Kgs1 -> "1_kings"
    | Kgs2 -> "2_kings"
    | Chr1 -> "1_chronicles"
    | Chr2 -> "2_chronicles"
    | Ezra -> "ezra"
    | Neh -> "nehemiah"
    | Esth -> "esther"
    | Job -> "job"
    | Psa -> "psalms"
    | Prov -> "proverbs"
    | Eccl -> "ecclesiastes"
    | Song -> "songs"
    | Isa -> "isaiah"
    | Jer -> "jeremiah"
    | Lam -> "lamentations"
    | Ezek -> "ezekiel"
    | Dan -> "daniel"
    | Hos -> "hosea"
    | Joel -> "joel"
    | Amos -> "amos"
    | Obad -> "obadiah"
    | Jonah -> "jonah"
    | Mic -> "micah"
    | Nah -> "nahum"
    | Hab -> "habakkuk"
    | Zeph -> "zephaniah"
    | Hagg -> "haggai"
    | Zech -> "zechariah"
    | Mal -> "malachi"
    | _ -> ""
  in
  "https://biblehub.com/"
  ^ book_str
  ^ "/"
  ^ (address.chapter |> Int.to_string)
  ^ "-"
  ^ (address.verse |> Int.to_string)
  ^ ".htm#combox"

let find_oblubienica_address address =
  let open Address in
  let book_no = Address.book_to_int address.book in
  let book_nt_no = book_no - 39 |> Int.to_string in
  "https://biblia.oblubienica.eu/interlinearny/index/book/"
  ^ book_nt_no
  ^ "/chapter/"
  ^ (address.chapter |> Int.to_string)
  ^ "/verse/"
  ^ (address.verse |> Int.to_string)

let find_url address =
  match Testament.of_address address with
  | OT -> find_ot_bible_hub_address address
  | NT -> find_oblubienica_address address
