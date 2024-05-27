open! Base

let%test "find ot verse url" =
  let url =
    Back.InterlinearBibleAccess.find_url {book= Prov; chapter= 27; verse= 4}
  in
  String.equal url "https://biblehub.com/proverbs/27-4.htm#combox"

let%test "find nt verse url" =
  let url =
    Back.InterlinearBibleAccess.find_url {book= Cor1; chapter= 1; verse= 2}
  in
  String.equal
    url
    "https://biblia.oblubienica.eu/interlinearny/index/book/7/chapter/1/verse/2"
