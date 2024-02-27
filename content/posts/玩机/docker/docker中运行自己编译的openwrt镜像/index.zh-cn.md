---
date: 2024-01-26T12:37:08+08:00
lastmod: 2024-02-27T08:34:51+08:00
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

# 给openwrt设置初始化ip地址
RUN echo "uci set network.lan.ipaddr='192.168.30.99' \
        && uci set network.lan.gateway='192.168.30.1' \
        && uci set network.lan.dns='192.168.30.1' \
        && uci commit" > /etc/uci-defaults/99-custom

ENTRYPOINT ["/sbin/init"]
```

注意这里的ADD使用绝对路径时，是以当前context为根目录，所以你必须把镜像文件复制到当前目录，也就是说，你不能够写成 `#ADD /root/mybuild/openwrt/bin/targets/x86/64/openwrt-x86-generic-generic-rootfs.tar.gz /`


创建docker虚拟网卡以便于分配独立的ip
```
docker network create -d macvlan --subnet=192.168.30.0/24 --gateway=192.168.30.1 -o parent=eno1 macnet
```


test
```
docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=eno1 macnet
```


```
docker run -d --name openwrt --restart always -d --network macnet --privileged  bleachwrt/plus /sbin/init
```


### 编写docker-compose.yaml
```
vim docker-compose.yaml
```
内容如下
```yaml
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
    external: true  # 使用已有的虚拟网卡
```


当然，也可以在docker-compose里面编写虚拟网卡参数，当执行`docker compose up` 时，会自动创建虚拟网卡，需要注意的是，同一个网卡只能创建一个虚拟网络     

例如，开头我们已经为eno1创建了192.168.30.0/24的网络，名称为macnet，此时则不能继续用eno1作为上游网卡
```
Error response from daemon: network dm-204e4605b2fe is already using parent interface eno1
```


所以如果你打算把创建虚拟网络的命令放进docker compose里面，则需要先删掉已有的虚拟网卡

```
docker network rm macnet
```

此时docker-compose.yaml就写成
```yaml
version: '3'

services:
  openwrt:
    #image: piaoyizy/openwrt-x86
    build: .
    container_name: my-openwrt
    privileged: true
    restart: always
    networks:
      macnet:
        ipv4_address: 192.168.30.99

networks:
  macnet: # 虚拟网卡2
    driver: macvlan
    driver_opts:
      parent: eno1 # 对应桥接的网卡
    ipam:
      config:
        - subnet: 192.168.30.0/24
          gateway: 192.168.30.1
```

注意，这里虚拟网卡分配的ip地址是指容器获取的ip地址，并不会直接应用到openwrt镜像的`/etc/config/network`里面，如果我们需要修改`/etc/config/networ`的配置，请在Dockerfile中使用`uci set network.lan.ipaddr='xxx'` 方式修改

### 启动openwrt容器
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
- 注意，由于我们在Dockerfile中已经使用了`uci set network.ipaddr`等命令设置了网络，因此这里实际上已经是修改后的了，此时你通过浏览器可以直接访问192.168.30.99进入后台

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


## 可能遇到的错误
### 在ip地址正确设置的情况下，web界面无法打开
猜测是你的镜像有问题，进入容器，查看一下网络监听状态，有没有80和443，如果没监听 0.0.0.0:80，那么就说明镜像可能有问题
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
### openwrt 无法访问web
原因是编译镜像的时候没有勾选luci，请勾选Luci->luci后重新编译！
![](Pasted%20image%2020240227151843.png)


### lede无法访问web的解决办法：
- https://forum.openwrt.org/t/luci-uhttpd-channel-3-open-failed-connect-failed/91646/2
- https://forum.openwrt.org/t/luci-not-available-anymore-ssh-works/22418/10

这是因为lede默认开启了https的访问，但是编译菜单没有勾选openssl，因此要么编译时候勾选openssl，要么关掉https

### 关掉https
```
uci set uhttpd.main.listen_https=''
uci commit
```
重启uhttpd
```
service uhttpd restart
```


```
service dockerd restart; sleep 5; logread -l 20
```

## 解决内核版本错误问题
https://openwrt.org/faq/cannot_satisfy_dependencies

编译的时候选择稳定版本的分支