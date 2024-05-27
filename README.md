# theos-logos.pl

## Deploy from a local computer

First run an ocaml image:

```bash
docker run -it ocaml/opam:debian-12-ocaml-5.1-afl bash
```

Switch to a different terminal and let the docker running.

Get the container id:

```bash
docker ps
```

(find first 4 letters from the ocaml/opam container, for me it was `106f`)

```bash
rm -rf .opam-docker
docker cp 106f:/home/opam/.opam ./.opam-docker
```

Now you can run `./deploy.sh` script.
The script assumes that you have this entry in your ~/.ssh/config file:

```
Host thlo
 Hostname 172.104.151.205
 user root
```

## Server preparation

- coppy ssh
```bash
ssh-copy-id root@172....
```

- install rsync

```bash
apt-get update
apt-get install rsync
```

- install nginx

```bash
apt-get install nginx
```

- install supervisord

```bash
apt-get install supervisor
systemctl enable supervisor
systemctl start supervisor
```

- create logs directory

```bash
mkdir -p /home/thl/theos_logos/logs
chown thl:thl /home/thl/theos_logos -R
```

- install certbot

```bash
apt-get install certbot
```

- generate certificate

```bash
certbot certonly
```