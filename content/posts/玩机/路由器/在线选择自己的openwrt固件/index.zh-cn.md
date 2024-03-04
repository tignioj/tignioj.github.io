---
date: 2024-03-04T10:23:58+08:00
lastmod: 2024-03-04T11:14:31+08:00
categories:
  - 玩机
  - 路由器
title: 在线选择自己的openwrt固件
draft: "false"
tags:
  - openwrt
  - immortalwrt
series:
---

## Immortalwrt
打开[固件选择器](https://firmware-selector.immortalwrt.org/)，左边选择你的机型，右边选择openwrt的版本，下方输入选择自己需要的软件
```
 lsblk fdisk parted cfdisk ntfs3-mount dmesg
 luci-app-openclash luci-app-dockerman luci-app-diskman luci-app-v2raya luci-app-samba4 luci-app-frpc luci-app-frps
 luci-app-ddns-go luci-app-fileassistant luci-app-wol luci-app-usb-printer luci-app-wifischedule luci-app-uugamebooster
 luci-app-alist luci-app-autoreboot luci-app-eqos luci-app-qos luci-app-qbittorrent luci-app-upnp luci-app-uhttpd
```

第二个空白栏输入初始化命令，例如初始化路由器的LAN地址
```
uci set network.lan.ipaddr='192.168.30.1'
uci commit
```


![](Pasted%20image%2020240304102407.png)


点击Request Build，就会开始构建，等待几分钟就会构建完成，下载即可。
![](Pasted%20image%2020240304103220.png)


刷机后发现很多插件都是英文版
![](Pasted%20image%2020240304111143.png)

这是因为没安装中文包，等我研究一下怎么搞中文包