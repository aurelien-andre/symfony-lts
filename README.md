# Symfony LTS

Version 5.4

## Requirements

| Service           | Version |
| ----------------- | ------- |
| OS Unix           | *       |
| Docker            | 20      |
| Docker-Compose    | 1.28    |

## Image

| Service           | Version       |
| ----------------- | ------------- |
| OS                | bullseye-slim |
| Nginx             | 1.18          |
| PHP               | 8.0           |
| Symfony           | 5.4           |
| Composer          | latest        |

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