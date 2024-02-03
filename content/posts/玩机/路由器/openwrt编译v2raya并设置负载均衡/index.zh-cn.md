---
date: 2024-01-27T18:49:51+08:00
lastmod: 2024-01-27T18:49:51+08:00
categories:
  - 玩机
  - 路由器
title: openwrt编译v2raya并设置负载均衡
draft: "false"
tags:
  - v2ray
  - v2raya
  - "#openwrt"
  - 科学上网
series:
---

## 添加软件源
找到这个列表 https://github.com/kenzok8/openwrt-packages
执行
```
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

选择luci-app-v2raya，然后编译即可。

## 负载均衡

openwrt启动后，打开v2raya界面发现只能选择单个，那是因为用了xray，xray不支持负载均衡，我们需要把核心切换成v2ray-core

### 下载v2ray核心并复制/usr/bin目录
```
opkg update; opkg install unzip wget-ssl
wget https://github.com/v2fly/v2ray-core/releases/download/v5.12.1/v2ray-linux-64.zip
unzip -d v2ray-core v2ray-linux-64.zip
cp v2ray-core/v2ray v2ray-core/v2ctl /usr/bin
chmod +x /usr/bin/v2ray; chmod +x /usr/bin/v2ctl
```

### 指定核心

```
uci set v2raya.config.v2ray_bin='/usr/bin/v2ray'
uci commit v2raya
```
事实上，上面这段命令会写入到`/etc/config/v2raya`，因此你也可以自己手动编辑该文件，具体用法请参考v2raya的官方文档
```
config v2raya 'config'
        option enabled '1'
        option address '0.0.0.0:2017'
        option ipv6_support 'auto'
        option nftables_support 'on'
        option log_level 'info'
        option log_max_days '3'
        option log_disable_color '1'
        option v2ray_bin '/usr/bin/v2ray'

```

## 参考： 
- [OpenWrt - v2rayA](https://v2raya.org/docs/prologue/installation/openwrt/)
- https://github.com/v2raya/v2raya-openwrt
