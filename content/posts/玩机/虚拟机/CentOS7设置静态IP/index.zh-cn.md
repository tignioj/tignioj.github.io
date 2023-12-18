---
date: 2023-12-18T20:59:14.720Z
lastmod: 2023-12-18T20:59:14.720Z
categories:
  - 玩机
  - 虚拟机
title: CentOS7设置静态IP
draft: "false"
tags:
  - Linux
  - CentOS7
series:
---
## 查看网关和子网掩码
![](Pasted%20image%2020231219045956.png)

## 修改网络配置ens33
```bash
cd /etc/sysconfig/network-scripts
```
![](Pasted%20image%2020231219050129.png)

添加如下内容
```
IPADDR=192.168.211.131
GATEWAY=192.168.211.2
NETMASK=255.255.255.0
DNS1=192.168.211.2
DNS2=8.8.8.8
DNS3=8.8.4.4
ONBOOT=yes
```
注意把ONBOOT=no改成YES，开机自动联网
![](Pasted%20image%2020231219050223.png)

参考
- https://www.cnblogs.com/xuchuangye/p/14250286.html
- https://www.snel.com/support/static-ip-configuration-centos-7/