---
date: 2024-03-02T05:08:53+08:00
lastmod: 2024-03-02T05:08:53+08:00
categories:
  - 玩机
  - Linux
title: Linux多网卡默认网关导致的问题和解决方案
draft: "false"
tags:
  - 默认网关
  - 路由表
series:
---
## 问题引入
UbuntuServer运行的docker突然不能科学上网，同时宿主机也如此，但是百度能ping通。
## 问题排查
我这台UbuntuServer有两个网卡，一个是以太网，一个是无线网。以太网连接了可以科学的路由器，而无线网则连接了一个普通的路由器。猜测数据没有经过以太网，而是经过了无线网络。

### 查看路由表`route -n`
```
root@tignioj:/home/tignioj# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.31.1    0.0.0.0         UG    0      0        0 wlp2s0
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 eno1
0.0.0.0         192.168.31.1    0.0.0.0         UG    600    0        0 wlp2s0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-d6b9d95bf4a3
172.19.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-776f3f29f447
172.26.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-d15248d82340
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eno1
192.168.1.1     0.0.0.0         255.255.255.255 UH    100    0        0 eno1
192.168.31.0    0.0.0.0         255.255.255.0   U     0      0        0 wlp2s0
192.168.31.1    0.0.0.0         255.255.255.255 UH    600    0        0 wlp2s0
```

可以看到有三个默认网关，Metric值越小，优先级越高，这里wlp2s0（无线网卡）的Metric的优先级最高，因此数据会默认经过无线网卡，而不是以太网（eno1）
```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.31.1    0.0.0.0         UG    0      0        0 wlp2s0
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 eno1
0.0.0.0         192.168.31.1    0.0.0.0         UG    600    0        0 wlp2s0
```

删掉第一条
```
route del default gw 192.168.31.1 wlp2s0
```

再次查看路由表，可以看到此时eno1的Metric是默认网关里面的最小值，优先级最高。
```
root@tignioj:/home/tignioj# route -n 
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.1     0.0.0.0         UG    100    0        0 eno1
0.0.0.0         192.168.31.1    0.0.0.0         UG    600    0        0 wlp2s0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
172.18.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-d6b9d95bf4a3
172.19.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-776f3f29f447
172.26.0.0      0.0.0.0         255.255.0.0     U     0      0        0 br-d15248d82340
192.168.1.0     0.0.0.0         255.255.255.0   U     0      0        0 eno1
192.168.1.1     0.0.0.0         255.255.255.255 UH    100    0        0 eno1
192.168.31.0    0.0.0.0         255.255.255.0   U     0      0        0 wlp2s0
192.168.31.1    0.0.0.0         255.255.255.255 UH    600    0        0 wlp2s0
```

测试google，就通了
```
root@tignioj:/home/tignioj# curl -I www.google.com
HTTP/1.1 200 OK
Content-Type: text/html; charset=ISO-8859-1

```


参考：修改路由表 https://www.cnblogs.com/djh5520/p/17104174.html