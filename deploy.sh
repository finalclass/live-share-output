#!/bin/bash

rsync -avz ./server/nginx.conf thlo:/etc/nginx/sites-available/default
rsync -avz ./server/supervisor.conf thlo:/etc/supervisor/conf.d/theos_logos.conf

ssh thlo "mkdir -p /home/thl/theos_logos/static"
rsync -avz ./static thlo:/home/thl/theos_logos/static

docker run -v "./:/theos_logos" -v "./.opam-docker:/home/opam/.opam" ocaml/opam:debian-12-ocaml-5.1-afl /theos_logos/build.sh

rsync -avz ./_build/default/bin/main.exe thlo:/home/thl/theos_logos/main.exe

ssh thlo "systemctl restart nginx supervisor"
ssh thlo "chown thl:thl /home/thl/theos_logos -R"
