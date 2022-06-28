FROM alpine:3.16.0

# expose port
EXPOSE 3306

ENV ROOT_PASSWORD 123

# update apk repositories
RUN apk update

# upgrade all
RUN apk upgrade

# install console tools
RUN apk add \
    inotify-tools

# install zsh
RUN apk add \
    zsh \
    zsh-vcs

# configure zsh
ADD --chown=root:root include/zshrc /etc/zsh/zshrc

# install mariadb
RUN apk add \
    mariadb \
    mariadb-client

# install timezone data
RUN apk add \
    tzdata

# enable remote connections to mariadb from any IP
RUN sed -i 's|skip-networking|#skip-networking|g' /etc/my.cnf.d/mariadb-server.cnf
RUN sed -i 's|#bind-address=0.0.0.0|bind-address=0.0.0.0|g' /etc/my.cnf.d/mariadb-server.cnf

# set server timezone to UTC
RUN sed -i "/^\[mysqld\]$/a default_time_zone='+00:00'" /etc/my.cnf.d/mariadb-server.cnf

# change mariadb log file
RUN touch /var/log/mysqld.log
RUN chown mysql:mysql /var/log/mysqld.log
RUN sed -i '/^\[server\]$/a log-error=\/var\/log\/mysqld.log' /etc/my.cnf.d/mariadb-server.cnf

# add entry point script
ADD --chown=root:root include/start.sh /tmp/start.sh

# make entry point script executable
RUN chmod +x /tmp/start.sh

# set working dir
WORKDIR /var/lib/mysql/

# set entrypoint
ENTRYPOINT ["/tmp/start.sh"]
