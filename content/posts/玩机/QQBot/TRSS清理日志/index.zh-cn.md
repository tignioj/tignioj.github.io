---
date: 2024-07-14T11:36:07+08:00
lastmod: 2024-07-14T11:36:07+08:00
categories:
  - 玩机
  - QQBot
title: TRSS清理日志
draft: "false"
tags:
  - TRSS
  - docker
series:
---

Docker 容器在运行时会生成大量日志文件，这些日志文件可能会占用大量磁盘空间。为了清理 Docker 日志，你可以按照以下步骤操作：

### 1. 配置 Docker 日志文件大小限制

通过限制 Docker 日志文件的大小和日志文件的数量，可以防止日志文件占用过多磁盘空间。编辑 `/etc/docker/daemon.json` 文件，添加以下配置：

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}

```


### 2. 重启 Docker 服务

应用更改后，需要重启 Docker 服务

```
sudo systemctl restart docker

```

### 3. 手动清理现有日志

对于已经存在的容器，你可以通过以下命令手动清理其日志文件：
```
truncate -s 0 /var/lib/docker/containers/*/*-json.log
```
这将清空所有容器的日志文件。

### 4. 使用 Docker 命令清理系统资源

除了清理日志文件，你还可以使用以下 Docker 命令清理系统资源，包括未使用的容器、镜像和卷：
```
# 删除所有停止的容器
docker container prune

# 删除所有未使用的镜像
docker image prune

# 删除所有未使用的卷
docker volume prune

# 删除所有未使用的网络
docker network prune

# 删除所有未使用的对象（包括停止的容器、未使用的镜像、未使用的卷和未使用的网络）
docker system prune

```