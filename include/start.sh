#!/bin/sh

echo ""
echo "Start container mariadb..."

# check if we should expose mariadb to host
# /docker/etc/ must be set in docker-compose
if [ -d /docker/etc/ ];
then
    echo "Expose mariadb to host..."
    sleep 3

    # check if config backup exists
    if [ ! -d /etc/my.cnf.d.bak/ ];
    then
        # create config backup
        echo "Expose mariadb to host - backup container config"
        cp -r /etc/my.cnf.d/ /etc/my.cnf.d.bak/
    fi

    # check if config exists on host
    if [ -z "$(ls -A /docker/etc/my.cnf.d/ 2> /dev/null)" ];
    then
        # config doesn't exist on host
        echo "Expose mariadb to host - no host config"

        # check if config backup exists
        if [ -d /etc/my.cnf.d.bak/ ];
        then
            # restore config from backup
            echo "Expose mariadb to host - restore config from backup"
            rm /etc/my.cnf.d/ 2> /dev/null
            cp -r /etc/my.cnf.d.bak/ /etc/my.cnf.d/
        fi

        # copy config to host
        echo "Expose mariadb to host - copy config to host"
        cp -r /etc/my.cnf.d/ /docker/etc/
    else
        echo "Expose mariadb to host - config exists on host"
    fi

    # create symbolic link so host config is used
    echo "Expose mariadb to host - create symlink"
    rm -rf /etc/my.cnf.d/ 2> /dev/null
    ln -s /docker/etc/my.cnf.d /etc/my.cnf.d

    echo "Expose mariadb to host - OK"
fi

# check if database exists
if [ -e /var/lib/mysql/ib_logfile0 ]
then
    echo "Database exists"

    # start mariadb
    echo "Start mariadb..."
    /usr/bin/mariadbd-safe --nowatch
else
    # create database
    echo "Create database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # start mariadb
    echo "Create database - start mariadb..."
    /usr/bin/mariadbd-safe --nowatch

    # check if mariadb is running
    if pgrep -x /usr/bin/mariadbd > /dev/null
    then
        # create root user with remote access
        echo "Create database - configure root user..."

        sleep 2

        mariadb <<-EOF
USE mysql;

# create user root with access from any host
CREATE USER 'root'@'%' IDENTIFIED BY '$ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

        # add timezone info to db
        echo "Create database - add timezone info..."
        mariadb-tzinfo-to-sql /usr/share/zoneinfo | mariadb mysql

        echo "Create database - OK"
    else
        echo "Create database - FAILED"
    fi
fi

# small sleep to allow mysql to start
sleep 1

# check if mariadb is running
if pgrep -x /usr/bin/mariadbd > /dev/null
then
    echo "----------------------------------------------------"
    echo "Start container mariadb - OK - ready for connections"
    echo "----------------------------------------------------"
    echo "host: localhost"
    echo "port: 3306"
    echo "user: root"
    echo "password: $ROOT_PASSWORD"
    echo "----------------------------------------------------"
else
    echo "Start container mariadb - FAILED - exit"
    echo "---------------------------------------"
    exit 1
fi

# https://www.ctl.io/developers/blog/post/gracefully-stopping-docker-containers/
# https://stackoverflow.com/questions/59521712/catching-sigterm-from-alpine-image
stop_container()
{
    echo ""
    echo "Stop container mariadb... - received SIGTERM signal"
    echo "Stop mariadb ..."
    killall -s SIGTERM mariadbd
    echo "Stop mariadb - OK"
    echo "Stop container mariadb - OK"
    exit 0
}

# catch termination signals
# https://unix.stackexchange.com/questions/317492/list-of-kill-signals
trap stop_container SIGTERM

restart_processes()
{
    sleep 0.5

    # restart mariadb
    echo "Restart mariadb..."

    killall -s SIGTERM mariadbd > /dev/null

    sleep 3
    /usr/bin/mariadbd-safe --nowatch
    sleep 3

    # check if mariadb is running
    if pgrep -x /usr/bin/mariadbd > /dev/null
    then
        echo "Restart mariadb - OK"
    else
        echo "Restart mariadb - FAILED - syntax error?"
    fi
}

# infinite loop, will only stop on termination signal
while true;
do
    # restart mariadb if any file in /etc/my.cnf.d changes
    inotifywait --quiet --event modify,create,delete --timeout 3 --recursive /etc/my.cnf.d/ && restart_processes
done
