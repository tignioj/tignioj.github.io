---
date: 2024-01-30T13:44:10+08:00
lastmod: 2024-01-30T13:44:10+08:00
categories:
  - 玩机
  - Linux
title: Linux磁盘管理-LVM
draft: "false"
tags:
  - 磁盘管理
  - Linux
  - LVM
series:
---

## LVM原理
- 系统不直接操作物理卷，而是操作逻辑卷LV，逻辑卷从VG池中获取，VG池子由物理卷划分的PE组成，一个PE默认是4M。
- 一个系统可以有多个LV和多个VG
- 可以动态调整LV空间而无需卸载硬盘

## 创建LVM

假设虚拟机添加了两张硬盘，目的：给这两张硬盘添加一个LVM卷组
![](Pasted%20image%2020240130134833.png)

虚拟机重启后，通过lsblk可以看到新加入的物理盘
![](Pasted%20image%2020240130135049.png)

### 创建PV

```
pvcreate /dev/sdc /dev/sdd
```

### 创建名称为myvg的卷组，并将PV加入卷组中
```
vgcreate myvg /dev/sdc /dev/sdd
```

查看myvg卷组信息`vgdisplay`或者`vgs`
- 可以看到Free  PE表示可以分配的内存有3G
```
root@ubuntu22lts:~# vgdisplay myvg
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               2.99 GiB
  PE Size               4.00 MiB
  Total PE              766
  Alloc PE / Size       0 / 0
  Free  PE / Size       766 / 2.99 GiB
  VG UUID               HaTT0k-GIgX-x8vr-QVki-Krpg-Vcw9-tSV6W8
```


### 基于myvg卷组创建名称为mylv1的逻辑卷LV
```
lvcreate -n mylv1 -L 512M myvg
```
查看逻辑卷信息`lvdisplay`或者`lvs`
- LV创建路径在VG子路径下
```
root@ubuntu22lts:~# lvdisplay /dev/myvg/mylv1
  --- Logical volume ---
  LV Path                /dev/myvg/mylv1
  LV Name                mylv1
  VG Name                myvg
  LV UUID                Fxrfkb-7E3z-ULcC-rjre-2M1m-Sdcy-k0XIqe
  LV Write Access        read/write
  LV Creation host, time ubuntu22lts, 2024-01-30 05:56:37 +0000
  LV Status              available
  # open                 1
  LV Size                512.00 MiB
  Current LE             128
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1
```


### 为创建好的逻辑卷mylv1创建文件系统
```
mkfs.ext4  /dev/myvg/mylv1
```

### 将格式化好的逻辑卷挂载使用
```
mount /dev/myvg/mylv1 /mnt
```

## 总结
![](Pasted%20image%2020240130141008.png)

## 删除LVM
注意一定要按顺序删除

### 取消挂载lv
```
umount /dev/myvg/mylv1
```
### 删除lv
注意，如果要删掉vg，则要删掉所有的lv，因为这里仅创建了mylv1，所以只需要删除它即可。
```
lvremove /dev/myvg/mylv1
```
### 删除VG
```
vgremove myvg
```
### 删除物理卷
```
pvremove /dev/sdc /dev/sdd
```



## 逻辑卷的拉伸（扩容）

### 保证VG中有足够的空闲空间
```
root@ubuntu22lts:~# vgdisplay
  --- Volume group ---
  VG Name               ubuntu-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <38.00 GiB
  PE Size               4.00 MiB
  Total PE              9727
  Alloc PE / Size       4863 / <19.00 GiB
  Free  PE / Size       4864 / 19.00 GiB
  VG UUID               op17oh-3MVI-EVTL-kfO1-7EyH-YJ1J-2XunOt
```
Free PE表示还有多少PE可以分配，每块PE大小默认是4M，这里有4864块，4864`*`4 大约是19G。

### 扩充逻辑卷
看下要扩充哪块LV，输入lvdisplay或者lvs，假设要扩充`/dev/ubuntu-vg/ubuntu-lv`
```
root@ubuntu22lts:~# lvdisplay
  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                wmFhA3-nMff-QYRL-J7Zi-kkVb-JTaC-YRG2dF
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2024-01-02 04:57:37 +0000
  LV Status              available
  # open                 1
  LV Size                <19.00 GiB
  Current LE             4863
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

```

扩充1G则输入命令
```
lvextend -L +1G /dev/ubuntu-vg/ubuntu-lv
```
扩充100%则输入命令
```
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```

查看结果`df -h`


## 参考：
- （推荐）1h的LVM视频教程： https://www.bilibili.com/video/BV16W411t7YY?p=2&vd_source=cdd8cee3d9edbcdd99486a833d261c72
	- P1: LVM原理
	- P2: LVM增删
	- P3: LVM扩容
	