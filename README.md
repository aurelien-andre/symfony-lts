![symfony](./doc/symfony.jpg)

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

# server:server-fpm_00             RUNNING   pid 11, uptime 0:16:39
# server:server-nginx_00           RUNNING   pid 10, uptime 0:16:39
```

```shell
supervisorctl restart server:*

# server:server-nginx_00: stopped
# server:server-fpm_00: stopped
# server:server-nginx_00: started
# server:server-fpm_00: started
```