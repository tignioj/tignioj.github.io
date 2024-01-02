---
date: 2024-01-02T13:30:01+08:00
lastmod: 2024-01-02T13:35:16+08:00
categories:
  - 玩机
  - 虚拟机
title: UbuntuServer22LTS设置静态IP
draft: "false"
tags:
  - ubuntu
  - 静态IP
series: 
---

编辑文档
```shell
sudo vim /etc/netplan/00-installer-config.yaml
```
添加以下内容
```
# This is the network config written by 'subiquity'
network:
  renderer: networkd
  ethernets:
    ens33:
      addresses:
        - 192.168.211.132/24  # 获取静态ip地址
      nameservers:
        addresses: [4.2.2.2, 8.8.8.8]
      routes:
        - to: default
          via: 192.168.211.2 # 网关IP
  version: 2
```

保存后，最后应用配置
```
sudo netplan apply
```

查看IP是否设置成功
```
ip addr show ens33
```

参考： https://linux.cn/article-15181-1.html