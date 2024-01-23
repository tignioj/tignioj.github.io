---
date: 2024-01-22T02:42:34+08:00
lastmod: 2024-01-22T02:42:34+08:00
categories:
  - 玩机
  - Linux
title: Ubuntu22LTS的ipv6连接方案
draft: "false"
tags:
  - IPv6
  - 路由表
  - ssh
series:
---
## 开放防火墙
小主机以太网连接二级路由，获取的是ipv6内网地址，而无线网连接的是一级路由（一级路由拨号，可以为设备分配公网ipv6），那么无线网络就拥有了公网ipv6。

为了能然互联网通过公网访问，先开放防火墙端口
```
ufw allow 8022
```

## ssh连接测试
我在wlp2s0接口使用了ddns解析到域名（假设为my.example.com)，由于手机默认支持ipv6，打算用手机用测试ssh连接该公网，发现卡住了
> [点击链接](https://ipw.cn/ipv6/) 测试你的手机是否支持ipv6
```
ssh tignoij@my.example.com -p 8022
```
于是添加 `-v` 参数查看详细的连接情况
```
ssh tignioj@my.example.com -p 8022 -v 
OpenSSH_8.6p1, OpenSSL 1.1.1l  24 Aug 2021
debug1: Reading configuration data /etc/ssh/ssh_config
debug1: Authenticator provider $SSH_SK_PROVIDER did not resolve; disabling
debug1: Connecting to my.example.com [ipv6地址] port 8022
```

与此同时，小主机可以通过命令查看端口监听状态
```
netstat -anpt | grep 8022
```
可以看到有有一个进程状态是`SYN_RECV`，这是TCP三次握手中的第二次握手连接状态，可知服务器收到了连接请求，但是无法发送TCP响应，意味着流量能进来但是出不去，排除防火墙的问题，因为第一步已经设置过ufw了
![](Pasted%20image%2020240122032909.png)

## 排查路由表
那么很有可能是路由表的问题，此时查看路由表可以看到，有两个默认网关（请忽视第三个我自己手动创建的）
![](Pasted%20image%2020240122024637.png)
猜测是流量走了错误的网关eno1，导致出不去，为了验证这个想法，手动删除eno1的默认网关
```
ip -6 route del default via fe80::ced8:43ff:fe9a:15d1 dev eno1
```
再次连接，仍旧失败，此时再次查看路由表，发现默认网关又被创建回来了。可能是这种删除路由表的办法不是永久的，于是使用netplan禁用eno1的ipv6，这样也不会创建该接口的路由表了
修改`vim /etc/netplan/00-installer-config.yaml` 
```
# This is the network config written by 'subiquity'
network:
  ethernets:
    eno1:
      dhcp4: true
  version: 2
```

## 禁用eno1网卡的ipv6
添加两行禁用以太网的ipv6
```
# This is the network config written by 'subiquity'
network:
  ethernets:
    eno1:
      dhcp4: true
      dhcp6: false
      accept-ra: no
  version: 2
```
执行命令应用网络设置
```
netplan apply
```
此时查看路由表发现eno1的默认网关已经消失了。然后手机再次尝试使用ssh连接即可成功连接上。
![](Pasted%20image%2020240122040045.png)

## 总结
1. ufw命令开放8022防火墙
2. 禁用eno1的内网ipv6，使得eno1的默认网关不要自动恢复

