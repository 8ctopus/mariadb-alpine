## project description

A super light docker MariaDB installation on top of Alpine Linux for development purposes

- MariaDB 10.4.12
- zsh

The docker image size is 188MB.

## cool features

- MariaDB configuration files are exposed on the host.
- All changes to the config files are automatically applied (hot reload).

## start container

    docker-compose up

    docker run -it -p 3306:3306 8ct8pus/mariadb-alpine

## connect to database

    hostname: localhost
    port: 3306
    user: root
    password: 123

## build docker image

    docker build -t 8ct8pus/mariadb-alpine:latest .

## more info about image

    https://wiki.alpinelinux.org/wiki/MariaDB
