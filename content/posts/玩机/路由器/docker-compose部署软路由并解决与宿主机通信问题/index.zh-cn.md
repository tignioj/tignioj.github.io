---
date: 2024-01-09T00:27:06+08:00
lastmod: 2024-01-20T15:07:11+08:00
categories:
  - 玩机
  - 路由器
title: docker-compose部署软路由并解决与宿主机通信问题
draft: "false"
tags:
  - 软路由
  - docker
series: 
---

## 原始方法
### docker原始方法创建macvlan

假设这张usb网卡作为LAN口，由于这个网段随意，只要不和WAN网段有重合即可
```bash
docker network create -d macvlan --subnet=10.10.10.0/24 --gateway=10.10.10.1 -o parent=enx98fc84e631d8 maclan
```

自带的以太网作为WAN口，设置网段为上级路由器同一个网段即可，网关指向路由器
```bash
docker network create -d macvlan --subnet=192.168.30.0/24 --gateway=192.168.30.1 -o parent=eno1 macwan 
```
- 注意，这里只是创建了虚拟网络，他们负责给容器分发ip地址。

使用docker-compose可以写成
```
networks:
  openwrt_maclan:
    driver: macvlan
    driver_opts:
      parent: enx98fc84e631d8 # 对应桥接的usb网卡
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
        - subnet: 192.168.30.0/24
          gateway: 192.168.30.1
```

具体参数信息请查看docker官网 https://docs.docker.com/compose/compose-file/06-networks/

### 将网络加入容器

```
version: '3'

services:
  openwrt:
    image: piaoyizy/openwrt-x86
    container_name: openwrt
    privileged: true
    restart: always
    networks:
      openwrt_maclan:
        ipv4_address: 10.10.10.6 # LAN口的IP，连接到此网卡的设备可以通过该ip访问openwrt后台
	  openwrt_macwan:
		ipv4_address: 192.168.30.99  # WAN口的IP
networks:
  openwrt_maclan:  # 虚拟网卡1
    driver: macvlan
    driver_opts:
      parent: enx98fc84e631d8 # 对应桥接的网卡
    ipam:
      config:
        - subnet: 10.10.10.0/24
          gateway: 10.10.10.1
  openwrt_macwan: # 虚拟网卡2
    driver: macvlan
    driver_opts:
      parent: eno1 # 对应桥接的网卡
    ipam:
      config:  # 注意WAN口的网段要和路由器的相同，否则无法联网
        - subnet: 192.168.30.0/24
          gateway: 192.168.30.1
```
参考: https://kingtam.win/archives/docker-openwrt.html#login
### 开启混杂模式
```
ip link set enx98fc84e631d8 promisc on
ip link set eno1 promisc on
```
### 启动容器
```
docker compose up -d
```
启动后，可以查看下容器的网络情况
![](Pasted%20image%2020240204041110.png)
这里笔者感到疑惑，明明同样的设定，openwrt是怎么区分LAN和WAN的呢？笔者的猜想是，到目前为止，openwrt并不能区分LAN和WAN，而是我们自己设置LAN和WAN。

## 容器网络配置

进入容器
```
docker compose exec openwrt ash
```

通过`ip a` 发现，lan并非是我们预期的`10.10.10.6`，而是被设置成了`192.168.30.99`（这是因为我之前编译openwrt的时候加入了自定义配置`uci set network.lan.ipaddr=192.168.30.99`，默认情况下是`192.168.1.1`，不同的作者编译的固件其静态ip不一样，但无论是哪个ip，这都不是我们想要的`10.10.10.6`，因此我们需要手动设置一下
- 固件编译时的自定义配置，默认是`192.168.1.1`
![](Pasted%20image%2020240204054753.png)

`ip a`查看到openwrt默认给虚拟USB网卡设置成了LAN
![](Pasted%20image%2020240204041702.png)
对于openwrt，大部分的配置文件都放在`/etc/config/`目录下，包括防火墙和各种应用的配置，对于接口ip地址的设置，有两种方法：
- 方法0：编译前就设置，显然这个固件已经编译好了，这个方法在此处无效。
- 方法1：直接修改`/etc/config/nework`
- 方法2：通过操作系统API  `uci set network.lan.ipaddr=10.10.10.6`，然后执行`uci commit` ，这两句执行完成后，设置会被写入到`/etc/config/network`

### 设置LAN和WAN

指定ip创建容器的时候，虽然docker会给容器分配ip地址，但是openwrt会对网卡做出以下默认初始化操作
- 让LAN自动设置为静态ip地址`192.168.1.1`（因为我固件编译时设置了192.168.30.99所以这里不是192.168.1.1)，
- 对WAN口自动设置为DHCP，导致他从路由器请求了一个不是我们创建虚拟网卡设置的ip，因此我们需要手动修改
 
 这里我们采取方法1来修改网络配置，执行`vim /etc/config/network` ， 先看下默认配置

```
config interface 'loopback'
        option device 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option ula_prefix 'fd74:a5b5:4545::/48'

config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.30.99'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option dns '192.168.30.1'
        option gateway '192.168.30.1'

config interface 'wan'
        option device 'eth1'
        option proto 'dhcp'
```
#### 修改LAN: 
- option ipaddr 设置为你的maclan的ip
```
config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'

config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '10.10.10.6'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option dns '10.10.10.6'
        option gateway '10.10.10.6'
```
此时修改完成后，重启容器
```
docker compose restart openwrt
```
这时候再次进入容器，就可以看到我们设置的lan口ip地址了
![](Pasted%20image%2020240204052630.png)
这个时候实际上已经可以联网了，因为WAN口通过DHCP向上级路由器获取到了`192.168.30.16`的ip地址。所以WAN口实际上也可以不配置，甚至在创建macvlan的时候，你都不需要设置subnet和gateway。

#### 修改WAN: 
其实不用修改也可以，默认DHCP就行了。
```
config interface 'wan'
        option device 'eth1'
        option proto 'dhcp'
```
如果非要修改
```
config interface 'wan'
        option device 'eth1'
        option proto 'static'
        option ipaddr '192.168.30.99'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option dns '192.168.30.1'
        option gateway '192.168.30.1'
```


openwrt重启网络
```
/etc/init.d/network restart
```

## 容器与宿主机的通讯修复


造成原因及解决方法说明

> 原因是部署 openWRT 系统时使用到了 docker 的 macvlan 模式，这个模式通俗一点讲就是在一张物理网卡上虚拟出两个虚拟网卡，具有不同的MAC地址，可以让宿主机和docker同时接入网络并且使用不同的ip，此时 docker 可以直接和同一网络下的其他设备直接通信，相当的方便，但是这种模式有一个问题，宿主机和容器是没办法直接进行网络通信的，如宿主机ping容器的ip，尽管他们属于同一网段，但是也是ping不通的，反过来也是。因为该模式在设计的时候，为了安全禁止了宿主机与容器的直接通信，不过解决的方法其实也很简单——宿主机虽然没办法直接和容器内的 macvlan 接口通信，但是只要在宿主机上再建立一个 macvlan，然后修改路由，使数据经由该 macvlan 传输到容器内的 macvlan 即可，macvlan 之间是可以互相通信的。


主机联通宿容器
```shell 
ip link add macvlan-proxy link enx98fc84e631d8 type macvlan mode bridge
ip addr add 192.168.10.99 dev macvlan-proxy
ip link set macvlan-proxy up
ip route add 192.168.10.9 dev macvlan-proxy
```

这时候容器就可以通过 192.168.10.99 访问宿主机了。
```
docker exec openwrt bash -c 'ping 192.168.10.99 -c 3'
```


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
ip link del macvlan-proxy link eno1 type macvlan mode bridge
ip addr del 192.168.31.99 dev macvlan-proxy
```

如果要让宿主机使用容器的网络，请添加默认网关
```
ip route add default via 192.168.10.9 dev macvlan-proxy
```

如果发现无法联网，需要去openwrt后台添加自定义防火墙规则

```
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
```

如果宿主机不想使用，可随时删掉默认网关
```
ip route del default via 192.168.10.9 dev macvlan-proxy
```


参考：
- https://www.treesir.pub/post/n1-docker/
- https://stackoverflow.com/questions/49600665/docker-macvlan-network-inside-container-is-not-reaching-to-its-own-host
- https://docs.docker.com/network/drivers/macvlan/