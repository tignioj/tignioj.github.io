---
date: 2023-11-12T15:48:37.607Z
lastmod: 2023-11-12T15:57:54.276Z
categories:
  - 玩机
  - 虚拟机
title: Vmware升级后无法ping通
draft: "false"
tags:
  - Vmware
  - 网络错误
series: 
description: 虚拟机无法ping通，修复后无法启动，修改vmx86.sys后再次修复重启
---

可能是网卡丢失导致的，我打开网络发现没有这两个网卡。于是打开Vmware17安装包点击修复，重启后就出现了。
![](Pasted%20image%2020231112234905.png)

但是又出现了新的错误：
```text
与 vmx86 驱动程序的版本不匹配: 预期为 416.0，实际为 360.0。
```

于是在网上找到帖子 https://www.zhihu.com/tardis/zm/art/403777914?source_id=1003

根据教程把 `vmx86.sys` 改成了 `vmx86.sys.bak`，然后再次修复重启，果然又恢复了



