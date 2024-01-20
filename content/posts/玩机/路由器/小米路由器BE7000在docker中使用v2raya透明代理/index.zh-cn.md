---
date: 2024-01-21T06:07:02+08:00
lastmod: 2024-01-21T06:07:02+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器BE7000在docker中使用v2raya透明代理
draft: "false"
tags:
  - 科学上网
  - v2raya
series:
---
首先请开启ssh，否则无权限。插入usb存储后，安装docker并启动，管理界面安装与否无所谓，关键是你要能进ssh。连接小米路由器ssh终端后，进入usb目录，找到docker的执行文件路径,这里的usb-xxx具体取决于你的设备。
```
cd /mnt/usb-cc5b5b23/mi_docker/docker-binaries
```
并在该目录下执行
```
./docker run -d \
  --restart=always \
  --privileged \
  --network=host \
  --name v2raya \
  -e V2RAYA_LOG_FILE=/tmp/v2raya.log \
  -e V2RAYA_V2RAY_BIN=/usr/local/bin/v2ray \
  -e V2RAYA_NFTABLES_SUPPORT=off \
  -e IPTABLES_MODE=legacy \
  -v /lib/modules:/lib/modules:ro \
  -v /etc/resolv.conf:/etc/resolv.conf \
  -v /etc/v2raya:/etc/v2raya \
  mzz2017/v2raya
```

查看容器是否成功运行，看到v2raya的STATUS为UP状态表明重启已经成功创建并运行。
```
root@XiaoQiang:/mnt/usb-cc5b5b23/mi_docker/docker-binaries# ./docker ps
CONTAINER ID   IMAGE            COMMAND    CREATED         STATUS         PORTS     NAMES
1ba7ea87cb45   mzz2017/v2raya   "v2raya"   9 minutes ago   Up 9 minutes             v2raya
```

然后你就可以进入路由器的IP:2017 进入v2raya后台管理界面，首次需要创建账号和密码。导入自己的服务后，右上角设置开启透明代理即可。