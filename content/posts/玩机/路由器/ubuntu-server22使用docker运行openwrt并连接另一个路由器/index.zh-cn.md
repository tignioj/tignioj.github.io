---
date: 2024-01-02T15:18:55+08:00
lastmod: 2024-01-03T09:54:11+08:00
categories:
  - 玩机
  - 路由器
title: ubuntu-server22使用docker运行openwrt并连接另一个路由器
draft: "false"
tags:
  - openwrt
  - docker
  - 软路由
series: 
---
## 网络结构
![](c7243f06b222617eea70f1bc455d36a.jpg)

## 安装docker-openwrt
下载[最新版openwrt](https://hub.docker.com/r/piaoyizy/openwrt-x86), 由于指定 latest标签可能未必是最新版，因此手动指定Digest版本下载
```
docker pull piaoyizy/openwrt-x86@sha256:8f7ee2290e31a971818e71a4e53fc58b985afcbf5f181ea5fed2c528ff53542b
```

### 宿主机的网络设置
查看你的网络配置`ip a`
```
$ ip a

2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether xxxxxx
    altname enp1s0
    inet 192.168.31.6/24 metric 100 brd 192.168.31.255 scope global dynamic eno1
       valid_lft 31022sec preferred_lft 31022sec

```
可以看到你的物理网卡为`eno1`, ipv4地址是`192.168.31.6`, 网关就是你路由器地址`192.168.31.1`

开启混杂模式
```
ip link set eno1 promisc on
```

 
创建macvlan
```
docker network create -d macvlan --subnet=192.168.31.0/24 --gateway=192.168.31.1 -o parent=eno1 macnet
```

### 创建openwrt容器并启动
```
docker run -d --name=openwrt --restart always --privileged --network macnet --ip 192.168.31.9 6f0f3db7c96d
```
- 这里的`6f0f3db7c96d`是你的openwrt镜像id（因为通过digest下载的镜像，其tag为none，只能通过id指定镜像）
- `--ip` 是为openwrt分配新的ip，要求路由器1上没有冲突的ip

### 容器的网络设置
修改openwrt监听地址，先进入容器
```
docker exec -it openwrt bash
```

找到lan->ipaddr, 把  ·option ipaddr· 改为创建容器时候传入的ip，其他不用动
```
config interface 'lan'
        option type 'bridge'
        option ifname 'eth0'
        option proto 'static'
        option ipaddr '192.168.31.9'
        option netmask '255.255.255.0'
        option ip6assign '60'
```

接着重启网络配置
```
/etc/init.d/network restart
```

> 如果此时报错 request timeout, 执行`docker rm -f openwrt`删掉容器，换个地址重新启动容器。 


### openwrt的设置

进去你路由器1后台看看是否有新设备加入。
![](Pasted%20image%2020240103095232.png)
打开浏览器，输入该ip地址，进入openwrt管理界面，默认账号密码：
- 账号:`root`
- 密码:`password`

#### 解决无法上网问题
此时路由器没有配置DNS是无法上网的，我们需要手动配置一下。
1. 接口->LAN->物理设置，取消桥接
2. 基本设置，填写网关和DNS(重要)
	> DNS和网关就是你路由器1地址

![](Pasted%20image%2020240103000338.png)
3. 设置防火墙规则，否则无法连接国内网站
	1. 网络->防火墙->自定义规则，添加一行
```
iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
```
解放无法上网的问题参考：
1. https://github.com/coolsnowwolf/lede/issues/5520#issuecomment-1258094178
2. https://www.right.com.cn/forum/thread-4453763-1-1.html

点击应用&保存。接着去 `网络`->`网络诊断` 测试能否PING通
![](Pasted%20image%2020240103000504.png)


### 配置科学上网：
`服务`->`PassWall`->`节点订阅` -> `添加`->`保存&应用`


## 路由器2设置

连接路由器1，随便使用一个不冲突的静态IP，将网关和DNS指向openwrt的后台地址即可

- 安装参考： https://www.bilibili.com/video/BV1d3411J7bp/?spm_id_from=333.337.search-card.all.click&vd_source=cdd8cee3d9edbcdd99486a833d261c72
- 配置参考
	- https://www.bilibili.com/video/BV1P54y167sj/?spm_id_from=333.337.search-card.all.click&vd_source=cdd8cee3d9edbcdd99486a833d261c72
	- https://www.cfmem.com/2021/08/docker-openwrt.html


