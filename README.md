## project description

A super light docker MariaDB installation on top of Alpine Linux for development purposes

- MariaDB 10.5.11
- zsh 5.8

The docker image size is 181 MB.

## cool features

- MariaDB configuration files are exposed on the host.
- All changes to config files are automatically applied (hot reload).

## start container

```sh
docker-compose up
```

## connect to database

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

## build docker image

```sh
docker build -t mariadb-alpine:dev .
```

## extend the docker image

In this example, we add curl.

```sh
docker-compose up --detach
docker exec -it mariadb zsh
apk add curl
exit

docker-compose stop
docker commit mariadb mariadb-alpine-curl:dev
```

To use the new image, update the image link in the docker-compose file.

## more info about the image

    https://wiki.alpinelinux.org/wiki/MariaDB
