![symfony](https://symfony.com/logos/symfony_black_02.svg)

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
| NodeJs            | 16            |
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
