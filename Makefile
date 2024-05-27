APP_NAME := theos_logos
.PHONY: all test clean

dune-watch:
	SECRET_KEY="local-secret-key" eval `opam env` && dune exec --watch $(APP_NAME)

css-watch:
	npx tailwindcss -i static/style.base.css -o static/style.css --watch

surrdb:
	surreal start --bind 0.0.0.0:8920 -p pass -u root --allow-all file://surreal.db --log debug

sql:
	surreal sql -e ws://0.0.0.0:8920 -u root -p pass --pretty --ns tl --db tl

test:
	SECRET_KEY="" eval `opam env` && dune runtest
