---
date: 2024-01-26T12:37:08+08:00
lastmod: 2024-01-26T12:37:08+08:00
categories:
  - 玩机
  - docker
title: docker中运行自己编译的openwrt镜像
draft: "false"
tags:
  - openwrt
  - docker
series:
---
## 准备docker镜像
```
mkdir my-openwrt && cd my-openwrt
```

复制编译好的`openwrt-x86-64-generic-rootfs.tar.gz` 到 `my-openwrt`

```
cp ~/mybuild/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-rootfs.tar.gz .
```

编写Dockerfile
```
# 从空白镜像创建
FROM scratch
ADD openwrt-x86-64-generic-rootfs.tar.gz /
EXPOSE 80 22 443
ENTRYPOINT ["/sbin/init"]
```
注意这里的ADD使用绝对路径时，是以当前context为根目录，所以你必须把镜像文件复制到当前目录，也就是说，你不能够写成 `#ADD /root/mybuild/openwrt/bin/targets/x86/64/openwrt-x86-generic-generic-rootfs.tar.gz /`

### 编写docker-compose.yaml
```
vim docker-compose.yaml
```
内容如下
```
version: '3'

services:
  openwrt:
    build: .
    container_name: my-openwrt
    privileged: true
    restart: always
    networks:
      macnet:
        ipv4_address: 192.168.30.99  # 从虚拟网卡macnet中分配ip

networks:
  macnet:  # 虚拟网卡1
    external: true

```

创建docker虚拟网卡以便于分配独立的ip
```
docker network create -d macvlan --subnet=192.168.30.0/24 --gateway=192.168.30.1 -o parent=eno1 macnet
```

启动docker
```
docker compose up -d
```

进入容器
```
docker compose exec openwrt ash
```

编辑网络
```
vi /etc/config/network
```

设置静态ip和dns以及gateway，注意，只有配置了dns和网关你才能让openwrt上网。
```
config device                                  
        option name 'br-lan'
        option type 'bridge'
        list ports 'eth0'   
                            
config interface 'lan'   
        option device 'br-lan'
        option proto 'static' 
        option ipaddr '192.168.30.99'
        option dns '192.168.30.1'    
        option gateway '192.168.30.1'
        option netmask '255.255.255.0'
        option ip6assign '60'  

```
编辑完成后，不要使用`/etc/init.d/network restart`，这样做很有可能卡住然后返回 `Request timeout`, 原因可能是路由表不正确，设置路由表还会报错，因此只能使用reboot或者退出容器重启改容器。
```
exit
docker compose restart openwrt
```

再进入容器，查看一下网络监听状态，有没有80和443
```
netstat -antp
```



如果没监听 0.0.0.0:80，则遇打不开后台
```
netstat -antp
```
发现压根没有监听80端口。
![](Pasted%20image%2020240126123813.png)
但是samba和ssh都可以连接，所以可以确定是web服务没有开启。
https://forum.openwrt.org/t/cant-access-openwrt-web-gui-luci/27914/12

手动开启一下
```
/usr/sbin/uhttpd -f -h /www -r 192.168.30.101 -x /cgi-bin -t 60 -T 30 -k 20 -A 1 -n 3 -N 100 -R -p 0.0.0.0:80
```
这下后台可以访问了，但是这显然不是正确的做法，目前进一步想办法解决。


## 解决web无法访问的问题 
原因是编译了非稳定版本的镜像，不包括luci，正确做法使用git tag选择稳定版本，然后勾选Luci->luici-light或者luci，重新编译！
![](Pasted%20image%2020240126162654.png)

 

## 解决内核版本错误问题
https://openwrt.org/faq/cannot_satisfy_dependencies

编译的时候选择稳定版本的分支