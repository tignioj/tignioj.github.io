---
date: 2023-11-10T12:29:40.750Z
lastmod: 2023-11-10T12:29:40.750Z
categories:
  - 玩机
  - Windows
title: 记录一次Windows网络排错
draft: "true"
tags:
  - 断网
  - Windows
series:
---
# 起因
尽管已经打开了Hyper-V和Virtual machine Platform，台式机WSL和安卓子系统仍然无法开启，于是尝试谷歌，点进去这样一篇文章
https://learn.microsoft.com/en-us/troubleshoot/windows-client/virtualization/cannot-create-hyper-v-virtual-switch

虽然没看太懂，但是看起来像是修复Hyper-V的东西，于是下载后运行，发现居然不能联网了。

## 排查驱动
- 首先是禁用、再启用驱动，无效
- 尝试过重启电脑、卸载驱动后再安装官网驱动仍旧无效。
- 插入无线网卡居然也无法联网，打开虚拟机直连无线网卡发现虚拟机可以通过无线网卡上网

这就奇怪了，为什么会这样呢？
特地去下载了360离线安装包，看看能不能有点帮助，打开断网修复工具后，提示网卡驱动有问题，但是官网的驱动总不至于吧？于是暂时跳过驱动的问题。

## 排查路由器
- 笔记本可以通过usb转千兆网卡正常连接，台式机有线连接甚至连路由器的主页都进不去。
- 笔记本WiFi也可连接上路由器。

证明路由器是没问题的


## 其他
- 重装Hyper-V、Virtual Platform无效

## 适配器功能排查
记得以前是再网卡配置那里有些功能逐个关闭排查，于是发现是把这个Network LightWeight Filter 关闭就好了。无线网卡驱动上同样关闭这个之后就能成功联网。

![](Pasted%20image%2020231110204318.png)
