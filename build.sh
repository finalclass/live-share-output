#!/bin/bash

cd /theos_logos

apt-get install libgmp-dev
opam init
opam install .
opam install ocaml
opam install dune
opam install lwt
opam install cohttp-lwt-unix
dune clean
dune build
