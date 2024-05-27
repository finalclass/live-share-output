type book =
  | Gen
  | Ex
  | Lev
  | Num
  | Deut
  | Josh
  | Judg
  | Ruth
  | Sam1
  | Sam2
  | Kgs1
  | Kgs2
  | Chr1
  | Chr2
  | Ezra
  | Neh
  | Esth
  | Job
  | Psa
  | Prov
  | Eccl
  | Song
  | Isa
  | Jer
  | Lam
  | Ezek
  | Dan
  | Hos
  | Joel
  | Amos
  | Obad
  | Jonah
  | Mic
  | Nah
  | Hab
  | Zeph
  | Hagg
  | Zech
  | Mal
  | Matt
  | Mark
  | Luke
  | John
  | Acts
  | Rom
  | Cor1
  | Cor2
  | Gal
  | Eph
  | Phil
  | Col
  | Thess1
  | Thess2
  | Tim1
  | Tim2
  | Titus
  | Phlm
  | Heb
  | Jas
  | Pet1
  | Pet2
  | John1
  | John2
  | John3
  | Jude
  | Rev

let book_to_int = function
  | Gen -> 1
  | Ex -> 2
  | Lev -> 3
  | Num -> 4
  | Deut -> 5
  | Josh -> 6
  | Judg -> 7
  | Ruth -> 8
  | Sam1 -> 9
  | Sam2 -> 10
  | Kgs1 -> 11
  | Kgs2 -> 12
  | Chr1 -> 13
  | Chr2 -> 14
  | Ezra -> 15
  | Neh -> 16
  | Esth -> 17
  | Job -> 18
  | Psa -> 19
  | Prov -> 20
  | Eccl -> 21
  | Song -> 22
  | Isa -> 23
  | Jer -> 24
  | Lam -> 25
  | Ezek -> 26
  | Dan -> 27
  | Hos -> 28
  | Joel -> 29
  | Amos -> 30
  | Obad -> 31
  | Jonah -> 32
  | Mic -> 33
  | Nah -> 34
  | Hab -> 35
  | Zeph -> 36
  | Hagg -> 37
  | Zech -> 38
  | Mal -> 39
  | Matt -> 40
  | Mark -> 41
  | Luke -> 42
  | John -> 43
  | Acts -> 44
  | Rom -> 45
  | Cor1 -> 46
  | Cor2 -> 47
  | Gal -> 48
  | Eph -> 49
  | Phil -> 50
  | Col -> 51
  | Thess1 -> 52
  | Thess2 -> 53
  | Tim1 -> 54
  | Tim2 -> 55
  | Titus -> 56
  | Phlm -> 57
  | Heb -> 58
  | Jas -> 59
  | Pet1 -> 60
  | Pet2 -> 61
  | John1 -> 62
  | John2 -> 63
  | John3 -> 64
  | Jude -> 65
  | Rev -> 66

let int_to_book = function
  | 1 -> Gen
  | 2 -> Ex
  | 3 -> Lev
  | 4 -> Num
  | 5 -> Deut
  | 6 -> Josh
  | 7 -> Judg
  | 8 -> Ruth
  | 9 -> Sam1
  | 10 -> Sam2
  | 11 -> Kgs1
  | 12 -> Kgs2
  | 13 -> Chr1
  | 14 -> Chr2
  | 15 -> Ezra
  | 16 -> Neh
  | 17 -> Esth
  | 18 -> Job
  | 19 -> Psa
  | 20 -> Prov
  | 21 -> Eccl
  | 22 -> Song
  | 23 -> Isa
  | 24 -> Jer
  | 25 -> Lam
  | 26 -> Ezek
  | 27 -> Dan
  | 28 -> Hos
  | 29 -> Joel
  | 30 -> Amos
  | 31 -> Obad
  | 32 -> Jonah
  | 33 -> Mic
  | 34 -> Nah
  | 35 -> Hab
  | 36 -> Zeph
  | 37 -> Hagg
  | 38 -> Zech
  | 39 -> Mal
  | 40 -> Matt
  | 41 -> Mark
  | 42 -> Luke
  | 43 -> John
  | 44 -> Acts
  | 45 -> Rom
  | 46 -> Cor1
  | 47 -> Cor2
  | 48 -> Gal
  | 49 -> Eph
  | 50 -> Phil
  | 51 -> Col
  | 52 -> Thess1
  | 53 -> Thess2
  | 54 -> Tim1
  | 55 -> Tim2
  | 56 -> Titus
  | 57 -> Phlm
  | 58 -> Heb
  | 59 -> Jas
  | 60 -> Pet1
  | 61 -> Pet2
  | 62 -> John1
  | 63 -> John2
  | 64 -> John3
  | 65 -> Jude
  | 66 -> Rev
  | _ -> failwith "Invalid book number"

type t =
  { book: book
  ; chapter: int
  ; verse: int }

let to_list addr = [addr.book |> book_to_int; addr.chapter; addr.verse]

let is_equal a b = a |> book_to_int = (b |> book_to_int)

let to_bible_id addr =
  let book, chapter, verse =
    match addr |> to_list with
    | [a; b; c] -> (a |> Int.to_string, b |> Int.to_string, c |> Int.to_string)
    | _ -> failwith "impossible"
  in
  "bible:[" ^ book ^ "," ^ chapter ^ "," ^ verse ^ "]"
