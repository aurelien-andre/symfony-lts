# Symfony LTS

Version 5.4

## Requirements

| Service           | Version |
| ----------------- | ------- |
| OS Unix           | *       |
| Docker            | 20      |
| Docker-Compose    | 1.28    |

## Image (rootless)

| Service           | Version       |
| ----------------- | ------------- |
| OS                | bullseye-slim |
| Nginx             | 1.18          |
| PHP               | 8.0           |
| Symfony           | 5.4           |

## Install

Open hosts

```
sudo nano /etc/hosts
```

Copy rules

```
127.0.0.1       www.traefik.lan
127.0.0.1       www.phpmyadmin.lan
127.0.0.1       www.symfony.lan
```

Install composer

```shell
# @see https://getcomposer.org/download/
wget -q https://getcomposer.org/download/latest-stable/composer.phar; \
mv composer.phar docker/bin-composer
```

Install mailHog (local)

```shell
# @see https://github.com/mailhog/mhsendmail/releases
wget -q https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64; \
mv mhsendmail_linux_amd64 docker/bin-mhsendmail
```

Build image

```shell
docker build . -t aurelienandre/symfony-lts:latest \
--build-arg UID=$(id -u) \
--build-arg GID=$(id -g)
```

Start containers

```shell
docker-compose up
```

## PHP

### Configuration

To configure php, use the environment variable.

Eg. set memory_limit = -1

PHP_MEMORY_LIMIT = -1

Eg. set opcache.enable = 1

PHP_OPCACHE__ENABLE = 1

the "PHP_" prefix is removed and the double underscores are replaced by dots

The entire configuration overlay is in the docker image

```shell
cat /etc/php/8.0/90-php.ini
```

## Supervisor

```shell
supervisorctl help

# default commands (type help <topic>):
# =====================================
# add    exit      open  reload  restart   start   tail   
# avail  fg        pid   remove  shutdown  status  update 
# clear  maintail  quit  reread  signal    stop    version
```

```shell
supervisorctl

# server:service-fpm_00            RUNNING   pid 8, uptime 0:00:19
# server:service-nginx_00          RUNNING   pid 7, uptime 0:00:19
```

```shell
supervisorctl restart server:*

# server:service-nginx_00: stopped
# server:service-fpm_00: stopped
# server:service-nginx_00: started
# server:service-fpm_00: started
```
