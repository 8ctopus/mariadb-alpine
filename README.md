## project description

A super light docker MariaDB installation on top of Alpine Linux for development purposes

- MariaDB 10.4.12
- zsh

The docker image size is 188 MB.

## cool features

- MariaDB configuration files are exposed on the host.
- All changes to the config files are automatically applied (hot reload).

## start container

    docker-compose up

    docker run -p 3306:3306 8ct8pus/mariadb-alpine:latest

## connect to database

    hostname: localhost
    port: 3306
    user: root
    password: 123

## build docker image

    docker build -t 8ct8pus/mariadb-alpine:latest .

## get console to container

    docker exec -it dev-db zsh

## extend the docker image

In this example, we add curl.

    docker-compose up --detach
    docker exec -it dev-web zsh
    apk add curl
    exit
    docker-compose stop
    docker commit dev-web user/mariadb-alpine-curl:latest

To use the new image, run it or update the image link in the docker-compose file.

## more info about image

    https://wiki.alpinelinux.org/wiki/MariaDB
