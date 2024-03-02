---
date: 2024-02-21T17:01:38+08:00
lastmod: 2024-02-21T17:01:38+08:00
categories:
  - 玩机
  - 路由器
title: RAX3000M-openwrt使用ipv6中继
draft: "false"
tags:
  - IPv6
  - openwrt
series:
---
中继教程：
https://www.lategege.com/?p=676

### 设置WAN6为DHCPv6客户端
![](Pasted%20image%2020240221170451.png)

### 设置WAN，DHCP服务器为中继，并设为主接口


WAN口的DHCP服务器设置
![](Pasted%20image%2020240221170555.png)


如果你没有这个选项，则WAN切换到静态模式，同时要进ssh编辑 `/etc/config/dhcp`

```
vi /etc/config/dhcp
```

找到wan，添加一行`option master '1'`

```
config dhcp 'wan'
        option interface 'wan'
        option ra 'relay'
        option dhcpv6 'relay'
        option ndp 'relay'
        option start '100'
        option limit '150'
        option leasetime '12h'
        option master '1'
```




### 设置LAN的DHCP为中继

![](Pasted%20image%2020240221170639.png)


