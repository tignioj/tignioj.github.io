---
date: 2024-01-18T02:17:36+08:00
lastmod: 2024-01-18T02:17:36+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器samba让WAN口设备访问
draft: "false"
tags:
  - samba
series:
---

首先你需要开启ssh，开启方法[请看这里](https://www.right.com.cn/forum/thread-8283638-1-1.html)
## samba设置
开启ssh后，编辑`/etc/samba/smb.conf.template`
```
[global]
        netbios name = |NAME|
        display charset = |CHARSET|
        interfaces = |INTERFACES|eth0
```
往interfaces中后面添加`eth0`
- 注意不能直接修改`smb.conf`，因为重启smb服务后会被自动修改。
- 为什么是`eth0`呢？你可以通过`ip a`查看哪个是你的WAN口
```
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether - brd ff:ff:ff:ff:ff:ff
    inet 192.168.31.26/2
```
接着重启samba
```
/etc/init.d/samba restart
```
查看是否监听成功
```
netstat -tapn | grep smbd
```
![](Pasted%20image%2020240118022226.png)
参考：
https://www.juyimeng.com/how-to-access-file-from-mi-wifi-wan.html

## 防火墙设置
编辑`/etc/config/firewall`文件，在文件最后添加以下内容：

```
config rule 'samba_udp'                                
        option src 'wan'                    
        option dest_port '137 138'             
        option proto 'udp'                                  
        option target 'ACCEPT'                  
        option name 'samba_incoming_udp'
 
config rule 'samba_tcp'        
        option src 'wan'                                   
        option dest_port '139 445'            
        option proto 'tcp'                
        option target 'ACCEPT'                 
        option name 'samba_incoming_tcp'
```

执行`/etc/init.d/firewall restart`命令重启防火墙

## 测试是否允许访问
电脑文件管理地址栏输入 `\\路由器WAN口ip`即可