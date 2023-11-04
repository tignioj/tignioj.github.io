---
title: Ubuntu安装Samba
date: 2023-11-05T03:09:00.000+08:00
draft: "false"
tags:
  - ubuntu
  - samba
lastmod: 2023-11-05T03:12:00.000+08:00
---



# 一、安装 `samba`

```xml
sudo apt update
sudo apt install samba
```

# 二、挂载硬盘

硬盘将要挂载的目录 `mkdir /home/<username>/sambashare/`

确定挂载的硬盘：
![](attachments/Pasted%20image%2020231105031112.png)


把硬盘挂载到刚刚创建的目录

```xml
sudo mount /dev/sdb1 home/<username>/sambashare/
```

检查是否挂载成功 `lsblk`
![](attachments/Pasted%20image%2020231105031132.png)

# 三、编写配置文件并创建用户

编辑 `sudo vim /etc/samba/smb.conf`

```xml
[sambashare]
    comment = Samba on Ubuntu
    path = /home/username/sambashare
    read only = no
    browsable = yes
```

创建smb用户

> Note：
> 
> Username used must belong to a system account, else it won’t save

```xml
sudo smbpasswd -a username
```

# 四、启动服务

```xml
sudo service smbd restart
```

# 参考
[Install and Configure Samba | Ubuntu](https://ubuntu.com/tutorials/install-and-configure-samba#1-overview)

[linux局域网共享文件夹和个人家庭影院搭建 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/355606638#:~:text=1.%E5%AE%89%E8%A3%85samba%2C%E5%AE%9E%E7%8E%B0%E6%96%87%E4%BB%B6%E5%A4%B9%E5%B1%80%E5%9F%9F%E7%BD%91%E5%86%85%E5%85%B1%E4%BA%AB%EF%BC%8C%E4%B9%9F%E6%96%B9%E4%BE%BF%E5%90%8E%E6%9C%9F%E9%80%9A%E8%BF%87%E7%94%B5%E8%84%91%E7%9B%B4%E6%8E%A5%E8%AE%BF%E9%97%AE%E7%AE%A1%E7%90%86%20%E5%AE%89%E8%A3%85%E5%91%BD%E4%BB%A4%EF%BC%8C%E8%BF%99%E9%87%8C%E4%BB%A5ubuntu%E4%B8%BA%E4%BE%8B%EF%BC%9A%20sudo%20apt-get,install%20samba%20samba-common%202.%E5%AE%89%E8%A3%85%E5%AE%8C%E5%90%8E%2C%E5%85%88%E5%A4%87%E4%BB%BDsamba%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%EF%BC%8C%E7%84%B6%E5%90%8E%E5%9C%A8%E6%96%B0%E5%BB%BA%E4%B8%80%E4%B8%AA%EF%BC%8C%E5%A1%AB%E5%86%99%E9%9C%80%E8%A6%81%E9%85%8D%E7%BD%AE%E7%9A%84%E5%86%85%E5%AE%B9)


