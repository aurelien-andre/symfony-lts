# Symfony LTS webpack-encore

## Documentation

https://symfony.com/doc/current/frontend.html

## Install

Install composer package

```shell
docker-composer run composer require symfony/webpack-encore-bundle
```

Update docker-composer.yml

```yaml
version: '3.8'

services:

  traefik:
    image: traefik:latest
    command: --api.insecure=true --providers.docker
    labels:
      - traefik.enable=true
      - traefik.http.routers.traefik.rule=Host(`www.traefik.lan`)
      - traefik.http.services.traefik.loadbalancer.server.port=8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80

  mysql:
    image: mysql:5.7
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    labels:
      - traefik.enable=false
    depends_on:
      - traefik
    volumes:
      - ./data/mysql:/var/lib/mysql:rw,delegated

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    environment:
      PMA_HOST: ${MYSQL_HOST}
      PMA_PORT: ${MYSQL_PORT}
      PMA_USER: ${MYSQL_USER}
      PMA_PASSWORD: ${MYSQL_PASSWORD}
    labels:
      - traefik.enable=true
      - traefik.http.routers.phpmyadmin.rule=Host(`www.phpmyadmin.lan`)
    links:
      - mysql
    depends_on:
      - traefik
      - mysql

  composer:
    image: composer
    command: install --prefer-dist --no-progress --no-interaction
    labels:
      - traefik.enable=false
    volumes:
      - ./src:/app:rw,delegated
    depends_on:
      - traefik

  # New service to build package js
  yarn:
    image: aurelienandre/yarn:latest
    command: yarn encore dev
    labels:
      - traefik.enable=false
    volumes:
      - ./src:/app:rw,delegated
    depends_on:
      - traefik

  symfony:
    image: aurelienandre/symfony-lts:latest
    env_file:
      - .env
    labels:
      - traefik.enable=true
      - traefik.http.routers.symfony.rule=Host(`www.symfony.lan`)
      - traefik.http.services.symfony.loadbalancer.server.port=80
    links:
      - mysql
    depends_on:
      - composer
      - yarn # Her add the dependency
      - traefik
      - mysql
    volumes:
      - ./src:/var/www/html:rw,delegated
```

Update /docker/docker-entrypoint

```shell
#!/bin/sh

if [ "$1" = 'supervisord' ]; then

  # NEW start
  # check of the webpack-encore build file
  while [ ! -f "/var/www/html/public/build/manifest.json" ]; do

    (echo >&2 "Waiting for Yarn to be ready...")

    sleep 2

  done
  # NEW end
  
  while [ ! -f "/var/www/html/vendor/autoload.php" ]; do

    (echo >&2 "Waiting for Composer to be ready...")

    sleep 2

  done

  if [ -n "$(ls -A /var/www/html/migrations/*.php 2>/dev/null)" ]; then

    until bin/console doctrine:query:sql "select 1" >/dev/null 2>&1; do

      (echo >&2 "Waiting for MySQL to be ready...")

      sleep 1

    done

    bin/console \
      doctrine:migrations:migrate \
      --no-interaction
  fi

  if [ -n "$(ls -A /var/www/html/public/bundles 2>/dev/null)" ]; then

    bin/console assets:install \
      --no-interaction

  fi

fi

if [ "$1" = 'supervisorctl' ]; then

  while [ ! -f "/var/pid/supervisord.pid" ]; do

    (echo >&2 "Waiting for Supervisor to be ready...")

    sleep 2

  done

fi

if [ "$1" = 'nginx' ] || [ "$1" = 'bin/console' ]; then

  while [ ! -f "/var/pid/php8.0-fpm.pid" ]; do

    (echo >&2 "Waiting for Fpm to be ready...")

    sleep 2

  done

fi

exec "$@"
```

Update .dockerignore

```text
/data
/src/var
/src/node_modules
/.git
/.gitignore
/.idea
/docker-compose.yml
/Dockerfile
/README.md
```

Update /src/.gitignore

```text
###> symfony/framework-bundle ###
/.env.local
/.env.local.php
/.env.*.local
/config/secrets/prod/prod.decrypt.private.php
/public/bundles/
/var/*
!/var/.gitignore
/vendor/*
!/vendor/.gitignore
###< symfony/framework-bundle ###

###> symfony/phpunit-bridge ###
.phpunit.result.cache
/phpunit.xml
###< symfony/phpunit-bridge ###

###> symfony/webpack-encore-bundle ###
/node_modules/*
!/node_modules/.gitignore
/public/build/*
!/public/build/.gitignore
npm-debug.log
yarn-error.log
###< symfony/webpack-encore-bundle ###
```

Build new image 

```shell
docker build -t . aurelienandre/symfony-lts:latest
```

Usage yarn

```shell
docker-compose run yarn
```

Add new package

```shell
docker-compose run yarn add your-package
```
