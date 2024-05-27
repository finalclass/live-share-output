open! Base

(* let%test "find one verse" = *)
(*   Ctx_helper.make_ctx *)
(*   @@ fun ctx -> *)
(*   let verse = *)
(*     Back.BibleAccess.find ~ctx (Address {book= Gen; chapter= 1; verse= 2}) *)
(*     |> List.hd_exn *)
(*   in *)
(*   String.is_substring verse.text ~substring:"A ziemia była" *)

(* let%test "find verses range" = *)
(*   Ctx_helper.make_ctx *)
(*   @@ fun ctx -> *)
(*   let verses = *)
(*     Back.BibleAccess.find *)
(*       ~ctx *)
(*       (AddressRange *)
(*          ({book= Gen; chapter= 1; verse= 1}, {book= Gen; chapter= 1; verse= 3}) *)
(*       ) *)
(*   in *)
(*   let third = *)
(*     match verses with *)
(*     | [_; _; third] -> third.text *)
(*     | _ -> "" *)
(*   in *)
(*   String.is_substring third ~substring:"I stała się światłość" *)

(* let%test "find chapter" = *)
(*   Ctx_helper.make_ctx *)
(*   @@ fun ctx -> *)
(*   let verses = Back.BibleAccess.find ~ctx (Chapter {book= Gen; chapter= 1}) in *)
(*   List.length verses = 31 *)

(* let%test "find by phrase" = *)
(*   Ctx_helper.make_ctx *)
(*   @@ fun ctx -> *)
(*   let verses = Back.BibleAccess.find ~ctx (Text "się światłość") in *)
(*   verses *)
(*   |> List.find ~f:(fun (v : Back.BibleAccess.t) -> *)
(*          Back.Address.is_equal v.address.book Gen *)
(*          && v.address.chapter = 1 *)
(*          && v.address.verse = 3 ) *)
(*   |> Option.map ~f:(fun _ -> true) *)
(*   |> Option.value ~default:false *)

let%test "create passage" =
  Ctx_helper.make_ctx
  @@ fun ctx ->
  let address_start : Back.Address.t = {book= Gen; chapter= 1; verse= 1} in
  let address_end : Back.Address.t = {book= Gen; chapter= 1; verse= 2} in
  Back.BibleAccess.create_passage ctx ~address_start ~address_end |> ignore ;
  let result = ctx.sq "SELECT * FROM passage" [] in
  List.length result = 1
