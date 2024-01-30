---
date: 2024-01-30T10:09:39+08:00
lastmod: 2024-01-30T10:09:39+08:00
categories:
  - 玩机
  - Linux
title: Ubuntu-Server2204LTS系统迁移
draft: "true"
tags:
  - Clonezilla
  - 再生龙
  - ubuntu
  - 系统迁移
  - YUMI
series:
---

## 创建启动盘

### 准备文件：
- 克隆工具：[clonezilla-live-3.1.1-27-amd64.iso](https://clonezilla.org/downloads/download.php?branch=stable)
- 创建启动盘工具：[YUMI-exFAT-1.0.2.5.exe](https://pendrivelinux.com/yumi-multiboot-usb-creator/)
打开YUMI，选择你的安装目的地，类型拉到System Tools选择安装类型为Clonezilla，第三步选择clonezilla的iso文件。如果找不到你的盘，你先把盘格式化为FAT32格式
![](Pasted%20image%2020240130162520.png)


### 进入启动盘
可能会遇到安全问题，选择ok，点进grub选择这个cer文件然后reboot即可。
![](Pasted%20image%2020240130172858.png)

## 克隆
通过USB启动后，选择System-Tools

![](Pasted%20image%2020240130231512.png)

找到clonezilla镜像，回车启动。
![](Pasted%20image%2020240130231548.png)

选择第一个Clonezilla live
![](Pasted%20image%2020240130231630.png)

选择语言为中文后，选择Start_Clonezilla使用再生龙
![](Pasted%20image%2020240130231659.png)

选择device-device克隆
![](Pasted%20image%2020240130231723.png)

初学者模式
![](Pasted%20image%2020240130231740.png)

disk to local disk
![](Pasted%20image%2020240130231750.png)

源镜像
![](Pasted%20image%2020240130231816.png)

目的镜像
![](Pasted%20image%2020240130231828.png)

跳过检查
![](Pasted%20image%2020240130231841.png)

![](Pasted%20image%2020240130231900.png)


警告数据即将清空，按下y确认
![](Pasted%20image%2020240130231933.png)

等待进度条走完
![](Pasted%20image%2020240130232004.png)

提示你要选择poweroff
![](Pasted%20image%2020240130232019.png)
poweroff
![](Pasted%20image%2020240130232052.png)

## 启动系统
克隆之后，此时两个磁盘的分区uuid相同，那么引导启动的时候就没办法决定启动哪个盘，解决办法
- 方法1：最简单，取下旧硬盘，保留新硬盘启动即可，此方法需要拆卸电脑。
- 方法2：不想拆卸电脑，那就要删除旧硬盘。

### 删除旧硬盘
进入再生龙命令列，会进入Debian系统
![](Pasted%20image%2020240130225926.png)
切换到root用户
```
sudo su root
```
输入cfdisk进入磁盘管理界面，逐个选择Delete
![](Pasted%20image%2020240130230221.png)

Delete完成之后，选择Write，按下回车，然后输入`yes` ，此时/dev/sda就没有旧的uuid信息了，然后重启电脑即可。
![](Pasted%20image%2020240130230307.png)



## 扩容
系统迁移到更大的硬盘后，会有一些空间没有被利用，我们需要把这些空闲的空间挂载到lvm中。

### 使用cfdisk创建新分区
输入`cfdisk`, 找到Free space，选择New，然后选择TYpe为LinuxFile System
![](Pasted%20image%2020240130230837.png)

最后选择Write回车，按下yes，此时/dev/sda4创建完成，接下来把sda4加入到ubuntu-vg容器卷

### VG扩容：

创建PV
```
pvcreate /dev/sdc
```

将PV加入到VG
```
vgcreate ubuntu-vg /dev/sda4
```


### LV扩容（从VG中获取）
```
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

更新文件系统
```
resize2fs /dev/ubuntu-vg/ubuntu-lv
```



## 总结：
1. 使用[YUMI](https://pendrivelinux.com/yumi-multiboot-usb-creator/)创建[Clonezilla](https://clonezilla.org/)的iso启动镜像到u盘，执行device-device的克隆操作。
2. 克隆之后，拔掉克隆前的硬盘或者进入再生龙命令用cfdisk删除旧硬盘，再启动系统进行扩容。
3. cfdisk创建新分区，将新分区加入到VG后，LV再从VG中获取存储空间


## 视频教程
- 创建启动盘： https://www.bilibili.com/video/BV1F4421A78J
- 克隆： https://www.bilibili.com/video/BV1Hv421i7fJ
- 扩容： https://www.bilibili.com/video/BV1Vv421i796

## 参考
- 迁移： https://askubuntu.com/questions/741723/moving-entire-linux-installation-to-another-drive
- 迁移图文教程： https://www.tecmint.com/linux-centos-ubuntu-disk-cloning-backup-using-clonezilla/
- 迁移视频教程： https://www.youtube.com/watch?v=41tTudaQb0I
-  扩容图文（详细）： https://askubuntu.com/questions/116351/increase-partition-size-on-which-ubuntu-is-installed
- 扩容： https://www.linuxtechi.com/extend-lvm-partitions/
