---
date: 2024-01-22T14:40:22+08:00
lastmod: 2024-01-22T14:40:22+08:00
categories:
  - 玩机
  - docker
title: docker使用镜像网站
draft: "true"
tags:
  - docker
  - 镜像
series:
---

搭建speedtest服务的时候发现docker拉取镜像的速度太慢了。
```
docker pull ghcr.io/librespeed/speedtest
```

使用国内的镜像站可以加速，只要把`ghcr.io`改为`ghcr.m.daocloud.io`即可
```
docker pull ghcr.io/librespeed/speedtest
```

其他镜像

| 源站 | 替换为 |
| ---- | ---- |
| cr.l5d.io | l5d.m.daocloud.io |
| docker.elastic.co | elastic.m.daocloud.io |
| docker.io | docker.m.daocloud.io |
| gcr.io | gcr.m.daocloud.io |
| ghcr.io | ghcr.m.daocloud.io |
| k8s.gcr.io | k8s-gcr.m.daocloud.io |
| registry.k8s.io | k8s.m.daocloud.io |
| mcr.microsoft.com | mcr.m.daocloud.io |
| nvcr.io | nvcr.m.daocloud.io |
| quay.io | quay.m.daocloud.io |
| registry.jujucharms.com | jujucharms.m.daocloud.io |
| rocks.canonical.com | rocks-canonical.m.daocloud.io |


参考： https://www.nenufm.com/dorthl/291/