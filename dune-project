(lang dune 3.14)

(name theos_logos)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name theos_logos)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
  (ocaml (= 5.1.1))
  (dune (= 3.15.0))
  (cohttp-eio (= 6.0.0~beta2))
  (eio (= 1.0))
  (eio_main (= 1.0))
  (base (= v0.16.3))
  (uri (= 4.4.0))
  (yojson (= 2.1.2))
  (ppx_deriving_yojson (= 3.7.0))
  (tyxml (= 4.6.0))
  (magic-mime (= 1.3.1))
 )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
