## docker mariadb alpine ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/8ct8pus/mariadb-alpine?sort=semver) ![Docker Pulls](https://img.shields.io/docker/pulls/8ct8pus/mariadb-alpine)

A super light docker `MariaDB` installation on top of Alpine Linux for developers.

- `MariaDB` 10.11.6
- `zsh` 5.9
- `Alpine` 3.19.1

_Note_: for the web server plus MariaDB, check https://github.com/8ctopus/php-sandbox

## cool features

- MariaDB configuration files are exposed on the host.
- All changes to config files are automatically applied (hot reload).

_Note_: On Windows [file changes notification to the container doesn't work with the WSL 2 engine](https://github.com/8ctopus/apache-php-fpm-alpine/issues), you need to use the `Hyper-V` engine. Uncheck `Use WSL 2 based engine`. What this means, is that files you update on Windows are not updated inside the container unless you use `Hyper-V`.

## quick start

- download [`docker-compose.yml`](https://github.com/8ctopus/mariadb-alpine/blob/master/docker-compose.yml)
- start `Docker Desktop` and run `docker-compose up`
- connect to MariaDB on `localhost`

    hostname: localhost
    port: 3306
    user: root
    password: 123 (ROOT_PASSWORD environmental variable)

## use container

Starting the container with `docker-compose` offers all functionalities.

```sh
# start container in detached mode on Windows in cmd
start /B docker-compose up

# start container in detached mode on linux, mac and mintty
docker-compose up &

# view logs
docker-compose logs -f

# stop container
docker-compose stop

# delete container but not volume which contains database
docker-compose down

# delete container and volume (database too)
docker-compose down -v
```

## get console to container

```sh
docker exec -it mariadb zsh
```

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

When you update the docker image version in `docker-compose.yml`, it's important to know that the existing configuration in the `docker` dir may cause problems.\
To solve all problems, backup the existing dir then delete it.

```sh
rm -rf docker/
```

## build development image

```sh
docker build -t mariadb-alpine:dev .
```

- update `docker-compose.yml`

```yaml
services:
  web:
    # development image
    image: mariadb-alpine:dev
```

## build docker image

_Note_: Only for repository owner

```sh
# build image
docker build --no-cache -t 8ct8pus/mariadb-alpine:1.0.12 .

# push image to docker hub
docker push 8ct8pus/mariadb-alpine:1.0.12
```

## more info about the image

    https://wiki.alpinelinux.org/wiki/MariaDB
