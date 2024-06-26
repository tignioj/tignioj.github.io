---
date: 2024-02-29T05:28:21+08:00
lastmod: 2024-03-01T13:25:34+08:00
categories:
  - 玩机
  - 路由器
title: RAX3000M使用官方OpenWRT的23.05.2一些问题以及解决方案
draft: "false"
tags:
  - openwrt
  - dockerman
  - docker
  - RAX3000M
series: 
---

## WiFi
首次启动需要自己手动开启WiFi


## 磁盘管理
### 分区
安装cfdisk和e2fsprogs
```
opkg updatee e2fsprogs
```
分配空闲磁盘
 ```
 cfdisk -l /dev/mmcblk0
```
选择FreeSpace，点击New创建新的存储空间，选择Write然后输入yes，会发现多出一个/dev/mmcblk0p6的存储空间
- 格式化新创建的存储空间
```
mkfs.ext4 /dev/mmcblk0p6
```

### 挂载
#### 方法1：手动挂载
手动挂载到/mnt
```
mkdir -p /mnt/mmcblk0p6
mount /dev/mmcblk0p6 /mnt/mmcblk0p6
```

#### 方法2：使用挂载点`blokc-mount`
最好在编译固件的时候就在`Base System` 中选中 `block-mount`，如果没有，则自己手动安装


#### 挂载docker

docker挂载到/mnt/mmcblk0p6
```
vi /etc/config/dockerd
```

找到`data_root`，修改`/opt/docker`为`/mnt/mmcblk0p6/docker`
```
config globals 'globals'
        option data_root '/mnt/mmcblk0p6/docker'
```
或者在web界面修改docker的挂载点。修改完成后，重启dockerd
```
service dockerd restart
```


## dockerman
- 编译luci-app-dockerman 需要自己手动勾选dockerd
- web界面的dockerman菜单项缺失，仅仅包含“配置”，则去`系统`->`软件包`， 先点击`更新列表`，然后选择更新`luci-lib-docker` 和`luci-i18n-dockerman-zh-cn`


## 尚未解决
1. 第一次安装了快照版本的initramfs文件，后续更新initramfs失效。


> 以下出现的问题均在按照完整的刷机流程刷一遍后得以解决(包括gpt, preloader, uboot, initramfs)

## DHCP
- 不知为何我的Ubuntu主机无法获取ip地址，即使执行dhclient 也无济于事，初步推断是插件引起的问题。但不确定是哪个。重启再等待一会就好了。

