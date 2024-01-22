---
date: 2024-01-22T11:25:12+08:00
lastmod: 2024-01-22T11:25:12+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器BE7000将docker命令添加到环境变量
draft: "false"
tags:
  - docker
  - 路由器
series:
---
## 添加docker命令到当前终端
进入终端，执行以下命令
```
DEVICE_UUID=$(uci -q get mi_docker.settings.device_uuid)
STORAGE_DIR=$(storage dump | grep -C3 "${DEVICE_UUID:-invalid-uuid}" | grep target: | awk '{print $2}')
DOCKER_DIR="${STORAGE_DIR:=/not_exist_disk}/mi_docker"
DOCKER_BIN="$DOCKER_DIR/docker-binaries"
export PATH=$PATH:$DOCKER_BIN
```
然后你就能使用docker命令了

## 持久化配置
为了让每次进入终端都无需手动配置环境变量，我们在开机自启的时候，把命令添加到/etc/profile里面。
> 首先你需要创建通用自启动脚本， 参考-> [index.zh-cn](../小米路由器BE7000开机自启通用脚本/index.zh-cn.md)，

创建一个脚本文件夹
```
mkdir -p /data/myscript
```
创建脚本`vim /data/myscript/env.sh`， 以下代码的环境变量是从`/etc/init.d/mi_docker`脚本中抄的
```
cat << 'EOF' >> /etc/profile
DEVICE_UUID=$(uci -q get mi_docker.settings.device_uuid)
STORAGE_DIR=$(storage dump | grep -C3 "${DEVICE_UUID:-invalid-uuid}" | grep target: | awk '{print $2}')
DOCKER_DIR="${STORAGE_DIR:=/not_exist_disk}/mi_docker"
DOCKER_BIN="$DOCKER_DIR/docker-binaries"
export PATH=$PATH:$DOCKER_BIN
EOF
```

```
chmod +x /data/myscript/env.sh
```

然后往startup_script里面添加启动命令
```
startup_script() {
	# docker env
	/data/myscript/env.sh
}
```
重启之后，会自动为profile文件添加环境变量