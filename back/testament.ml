type t =
  | OT
  | NT

let of_address address =
  let book_no = Address.(book_to_int address.book) in
  if book_no <= 39 then OT else NT
