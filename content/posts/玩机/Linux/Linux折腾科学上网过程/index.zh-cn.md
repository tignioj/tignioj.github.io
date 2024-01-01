---
title: Linux折腾科学上网过程
date: 2023-12-31T18:49:27+08:00
draft: "false"
tags:
  - Linux
  - 科学上网
  - clash
  - docker
  - v2ray
lastmod: 2024-01-01T08:54:15+08:00
categories:
  - 玩机
  - Linux
series: 
---

## [v2raya](https://github.com/v2rayA/v2rayA)代理
文档地址： https://v2raya.org/docs/prologue/introduction/
### docker方式启动
```
docker run -d \ 
--restart=always \ --privileged \ 
--network=host \ --name v2raya \ 
-e V2RAYA_LOG_FILE=/tmp/v2raya.log \ 
-e V2RAYA_V2RAY_BIN=/usr/local/bin/v2ray \ 
-e V2RAYA_NFTABLES_SUPPORT=off \ 
-e IPTABLES_MODE=legacy \ 
-v /lib/modules:/lib/modules:ro \ 
-v /etc/resolv.conf:/etc/resolv.conf \ 
-v /etc/v2raya:/etc/v2raya \ mzz2017/v2raya
```
- 配置文件会被写入到系统的/etc/v2raya，
- 由于是host模式，无需手动分配端口，启动成功后，直接打开浏览器访问 你的IP:2017
- 首次进入后台管理需要创建管理密码。
- 进入管理界面后导入订阅地址即可，订阅地址一定要国内可访问，否则会出现connection reset by peer的问题。

### Windows客户端
直接下载安装包双击运行后，打开localhost:2017导入配置即可。



尽管clash已经删库跑路了，但是还留了个docker镜像，可惜没有文档只能盲目摸索。
## clash代理
1. 准备好你的config.yaml文件
2. 创建`docker-compose.yml`文件,并添加如下内容：
```
version: '3.8'
services:
  clash:
    image: dreamacro/clash
    volumes:
      - ./config.yaml:/root/.config/clash/config.yaml
    ports:
      - "7890:7890"
      - "9090:9090"
    restart: always

  clash-dashboard:
    image: centralx/clash-dashboard
    container_name: clash-dashboard
    ports:
      - "9999:80"
    restart: always
```
3. 执行`docker compose -d` 后台启动该项目
- 9090是docker的后端调用地址，公网IP必须开启9090端口，因为dashboard要访问这个服务
- 7890是代理地址


### 设置clash地址
clash-dashboard只是查看clash配置的，所以要让dashboard连接上clash，而clash开启的9090端口提供了接口。
1. 第一步准备的`config.yaml`中可以修改clash的监听地址和端口
```
mixed-port: 7890
allow-lan: true
mode: Rule
log-level: info
secret: '访问密码'
external-controller: 0.0.0.0:9090 # clash监听地址和端口
```
2. 输入你的ip:9999，进入clash-dashboard的网页，会提示配置clash地址和端口，密码等信息。clash地址请输入公网IP！

### clash地址的困惑
令人感到困扰的是，在clash-dasboard容器内部执行`curl clash:9090`时，clash有响应，但是在web界面却无法设置host为`clash` (密码肯定是正确的)
```
root@iZwz9f6aasa5nbfbk126doZ:~/clash# docker compose exec clash-dashboard bash
root@10461afe8fa5:/# curl clash:9090
{"message":"Unauthorized"}
root@10461afe8fa5:/# 
```

设置失败！
![](Pasted%20image%2020231231185740.png)

于是尝试了下其他形式的IP，通过docker inspect 项目的网络，可以看到他们都在 `192.168.48.x` 同一网段下
```
"Containers": {
	"10461afe8fa569cb8ddbf53ffcb36b6789155d3cbdf8356596063ed5127fd8d3": {
		"Name": "clash-dashboard",
		"EndpointID": "09da4c8acdc52f672d82362a35d05f79f11047b2a3edb591cf92faa46f39d025",
		"MacAddress": "02:42:c0:a8:30:03",
		"IPv4Address": "192.168.48.3/20",
		"IPv6Address": ""
	},
	"d647ce609be8a47fe7670d82bd3b7d45895bb39ea1a38975d34e8f3f5d1184e3": {
		"Name": "clash-clash-1",
		"EndpointID": "a4975a9dfd13dfa7132fe84d08c5e421b48b5b8f7316f755c55612bb93bc3bfc",
		"MacAddress": "02:42:c0:a8:30:02",
		"IPv4Address": "192.168.48.2/20",
		"IPv6Address": ""
	}
},

```

通过 `ip a`查看docker网关地址，可以看到是`172.17.0.1`
```
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:24:44:77:ef brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:24ff:fe44:77ef/64 scope link 
```

在容器内通过局域网IP和docker0网关访问都没问题
```
root@iZwz9f6aasa5nbfbk126doZ:~/clash# curl 192.168.48.2:9090
{"message":"Unauthorized"}
root@iZwz9f6aasa5nbfbk126doZ:~/clash# curl 172.17.0.1:9090
{"message":"Unauthorized"}

```

但是在网页端仍然无法设置成功，最后发现只能设置成公网IP（需要在安全组开启端口）



### clash代理步骤总结
1. 使用`docker compose up -d`启动docker和面板
2. 复制你的配置文件到config.yml 
3. 在config.yml中配置以下两项
	- `secret: '后端控制密码'`
	- `external-controller: 0.0.0.0:9090` # 后端监听地址
4. 进入dashboard界面，连接clash的公网IP地址。


## 使用代理
1. 命令行设置快捷代理，请查看->[index.zh-cn](../终端添加代理命令/index.zh-cn.md)
2. 验证代理是否开启成功 `curl -I https://www.google.com` 




参考：

- docker compose 运行clash和dashboard https://silon.vip/post/51#%E5%88%9B%E5%BB%BA%E9%A1%B9%E7%9B%AE
