## docker mariadb alpine

A super light docker MariaDB installation on top of Alpine Linux for development purposes

- MariaDB 10.6.4
- zsh 5.8
- Alpine 3.15.0

The docker image size is 195 MB.

_Note_: for the web server plus MariaDB, check https://github.com/8ctopus/php-sandbox

## cool features

- MariaDB configuration files are exposed on the host.
- All changes to config files are automatically applied (hot reload).

_Note_: On Windows [hot reload doesn't work with WSL 2](https://github.com/microsoft/WSL/issues/4739), you need to use the legacy Hyper-V.

## use container

```sh
# start container on linux and mac in shell
docker-compose up &

# start container on Windows in cmd
start /B docker-compose up

# stop container
docker-compose stop

# delete container but not database which is on volume
docker-compose down

# delete container and database
docker-compose down -v
```

## connect to database

Use your favorite tool to connect. On Windows, you can try [HeidiSQL](https://github.com/HeidiSQL/HeidiSQL).

```
hostname: localhost
port: 3306
user: root
password: 123 (ROOT_PASSWORD environmental variable)
```

## get console to container

```sh
docker exec -it mariadb zsh
```

## use development image

- build docker development image

`docker build -t mariadb-alpine:dev .`

- `rm -rf etc log`
- in docker-compose.yml

```yaml
services:
  web:
    # development image
    image: mariadb-alpine:dev
```

- `docker-compose up`

## extend docker image

In this example, we add the php-curl extension.

```sh
docker-compose up --detach
docker exec -it mariadb zsh
apk add curl
exit

docker-compose stop
docker commit mariadb mariadb-alpine-curl:dev
```

To use the new image, update the image link in the docker-compose file.

## update docker image

When you update the docker image version, it's important to know that the existing configuration in `etc` may cause problems.
To solve the problems, backup your config then delete all config files:

```sh
rm -rf etc/ log/
```

## more info about the image

    https://wiki.alpinelinux.org/wiki/MariaDB
