---
date: 2024-01-28T19:35:20+08:00
lastmod: 2024-01-28T19:35:20+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器BE7000在docker运行AdGuardHome去广告插件
draft: "true"
tags: []
series: []
---

参考官网：  https://github.com/AdguardTeam/AdGuardHome/wiki/Docker

### Pull the Docker image

This command will pull the latest stable version:

```shell
docker pull adguard/adguardhome
```

### Create directories for persistent configuration and data

The image exposes two volumes for data and configuration persistence. You should create a **data** directory on a suitable volume on your host system, e.g. `/my/own/workdir`, and a **configuration** directory on a suitable volume on your host system, e.g. `/my/own/confdir`.

由于小米路由器root目录无法存放文件（重启后会被删掉），因此可以将docker数据存放到/data目录下
```
mkdir -p /data/docker/AdGuardHome/workdir
mkdir -p /data/docker/AdGuardHome/confdir
cd /data/docker/AdGuardHome
```
### Create and run the container

Use the following command to create a new container and run AdGuard Home:

```
docker run --name adguardhome\
    --restart unless-stopped\
    -v /data/docker/AdGuardHome/workdir:/opt/adguardhome/work\
    -v /data/docker/AdGuardHome/confdir:/opt/adguardhome/conf\
    -p 53:53/tcp -p 53:53/udp\
    -p 67:67/udp -p 68:68/udp\
    -p 80:80/tcp -p 443:443/tcp -p 443:443/udp -p 3000:3000/tcp\
    -p 853:853/tcp\
    -p 853:853/udp\
    -p 5443:5443/tcp -p 5443:5443/udp\
    -p 6060:6060/tcp\
    -d adguard/adguardhome
```