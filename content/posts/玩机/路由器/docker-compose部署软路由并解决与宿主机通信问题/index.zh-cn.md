---
date: 2024-01-09T00:27:06+08:00
lastmod: 2024-01-09T00:27:06+08:00
categories:
  - 玩机
  - 路由器
title: docker-compose部署软路由并解决与宿主机通信问题
draft: "true"
tags: []
series: []
---

### 前言
使用docker compose方法省去了繁琐的命令执行过程，例如docker原始方法创建macvlan
```
docker network create -d macvlan --subnet=192.168.10.0/24 --gateway=192.168.10.1 -o parent=enx98fc84e631d8 maclan

docker network create -d macvlan --subnet=192.168.31.0/24 --gateway=192.168.31.1 -o parent=eno1 macwan
```

而使用docker-compose可以写成
```
networks:
  openwrt_maclan:
    driver: macvlan
    driver_opts:
      parent: enx98fc84e631d8 # 对应桥接的网卡
    ipam:
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
  openwrt_macwan:
    driver: macvlan
    driver_opts:
      parent: macwan # 对应桥接的网卡
    ipam:
      config:
        - subnet: 192.168.31.0/24
          gateway: 192.168.31.1
```

这样会自动创建两个虚拟网卡，具体参数信息请查看docker官网 https://docs.docker.com/compose/compose-file/06-networks/

### 编写compose文件

```
version: '3'

services:
  openwrt:
    image: piaoyizy/openwrt-x86@sha256:ccfe467e8735c8cb121a790fb6b64476f7b83decd45bceefebb125b6924a8dcf
    container_name: openwrt
    privileged: true
    restart: always
    networks:
      openwrt_maclan:
        ipv4_address: 192.168.10.9 
	  openwrt_macwan:
networks:
  openwrt_maclan:  # 虚拟网卡1
    driver: macvlan
    driver_opts:
      parent: enx98fc84e631d8 # 对应桥接的网卡
    ipam:
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
  openwrt_macwan: # 虚拟网卡2
    driver: macvlan
    driver_opts:
      parent: eno1 # 对应桥接的网卡
    ipam:
      config:
        - subnet: 192.168.31.0/24
          gateway: 192.168.31.1
```

### 开启混杂模式
```
ip link set enx98fc84e631d8 promisc on
ip link set eno1 promisc on
```
### 启动容器
```
docker compose up -d
```


### 容器修改ip
进入容器
```
docker compose exec openwrt bash
```

编写网络配置 `vim /etc/config/network` ， 这里仅需修改 lan下的option ipaddr为docker compose 中lan指定的ipv4地址即可。
```
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd55:193a:aa94::/48'
        option packet_steering '1'

config interface 'lan'
        option type 'bridge'
        option ifname 'eth0'
        option proto 'static'
        option ipaddr '192.168.10.9'
        option netmask '255.255.255.0'
        option ip6assign '60'

config interface 'wan'
        option ifname 'eth1'
        option proto 'dhcp'

config interface 'wan6'
        option ifname 'eth1'
        option proto 'dhcpv6'

config interface 'utun'
        option proto 'none'
        option ifname 'utun'
        option device 'utun'

```


openwrt重启网络
```
/etc/init.d/network restart
```

### 容器与宿主机的通讯修复


造成原因及解决方法说明

> 原因是部署 openWRT 系统时使用到了 docker 的 macvlan 模式，这个模式通俗一点讲就是在一张物理网卡上虚拟出两个虚拟网卡，具有不同的MAC地址，可以让宿主机和docker同时接入网络并且使用不同的ip，此时 docker 可以直接和同一网络下的其他设备直接通信，相当的方便，但是这种模式有一个问题，宿主机和容器是没办法直接进行网络通信的，如宿主机ping容器的ip，尽管他们属于同一网段，但是也是ping不通的，反过来也是。因为该模式在设计的时候，为了安全禁止了宿主机与容器的直接通信，不过解决的方法其实也很简单——宿主机虽然没办法直接和容器内的 macvlan 接口通信，但是只要在宿主机上再建立一个 macvlan，然后修改路由，使数据经由该 macvlan 传输到容器内的 macvlan 即可，macvlan 之间是可以互相通信的。


主机联通宿容器
```shell 
ip link add dockerrouteif link enx98fc84e631d8 type macvlan mode bridge
ip addr add 192.168.10.99 dev dockerrouteif
ip link set dockerrouteif up
ip route add 192.168.10.9 dev dockerrouteif
```


这时候容器就可以通过 192.168.10.99 访问宿主机了。
```
oot@tignioj:~/dockercompose/openwrt# docker exec openwrt bash -c 'ping 192.168.10.99 -c 3'
PING 192.168.10.99 (192.168.10.99): 56 data bytes
64 bytes from 192.168.10.99: seq=0 ttl=64 time=0.088 ms
64 bytes from 192.168.10.99: seq=1 ttl=64 time=0.163 ms
64 bytes from 192.168.10.99: seq=2 ttl=64 time=0.166 ms

--- 192.168.10.99 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.088/0.139/0.166 ms
root@tignioj:~/dockercompose/openwrt# 
```


如果不需要通信，则可以删除
```
ip link del dockerrouteif link eno1 type macvlan mode bridge
ip addr del 192.168.31.99 dev dockerrouteif
```

参考：
- https://www.treesir.pub/post/n1-docker/
- https://stackoverflow.com/questions/49600665/docker-macvlan-network-inside-container-is-not-reaching-to-its-own-host
- https://docs.docker.com/network/drivers/macvlan/