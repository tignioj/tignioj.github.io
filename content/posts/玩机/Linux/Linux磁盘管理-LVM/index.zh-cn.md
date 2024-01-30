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
- 实际上还存在于/dev/mapper/myvg-mylv1
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
注意必须要格式化，否则无法挂载
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
逻辑卷的拉伸和缩小操作都可以在已经挂载的硬盘上执行，无需卸载磁盘
### 保证VG中有足够的空闲空间
- 通过vgdisplay命令查看剩余空间
```
root@ubuntu22lts:~# vgdisplay myvg
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               2.99 GiB
  PE Size               4.00 MiB
  Total PE              766
  Alloc PE / Size       128 / 512.00 MiB
  Free  PE / Size       638 / 2.49 GiB
  VG UUID               2v2iHd-jcx3-UWU3-8KIk-wmHe-wEb3-GCpJrS
```

- 或者vgs命令查看剩余空间
```
root@ubuntu22lts:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  myvg        2   1   0 wz--n-   2.99g  2.49g
  ubuntu-vg   1   1   0 wz--n- <38.00g 18.00g
```

Free PE表示还有多少PE可以分配，每块PE大小默认是4M，这里有638块，638`*`4 大约是2.5G。



### 扩充逻辑卷
看下要扩充哪块LV，输入`lvdisplay`或者`lvs`

```
root@ubuntu22lts:~# lvdisplay
  --- Logical volume ---
  LV Path                /dev/myvg/mylv1
  LV Name                mylv1
  VG Name                myvg
  LV UUID                idp0JM-STeC-T8L3-2d27-mlzY-Uqdr-dRIcrK
  LV Write Access        read/write
  LV Creation host, time ubuntu22lts, 2024-01-30 06:57:06 +0000
  LV Status              available
  # open                 0
  LV Size                512.00 MiB
  Current LE             128
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

  --- Logical volume ---
  LV Path                /dev/ubuntu-vg/ubuntu-lv
  LV Name                ubuntu-lv
  VG Name                ubuntu-vg
  LV UUID                wmFhA3-nMff-QYRL-J7Zi-kkVb-JTaC-YRG2dF
  LV Write Access        read/write
  LV Creation host, time ubuntu-server, 2024-01-02 04:57:37 +0000
  LV Status              available
  # open                 1
  LV Size                <20.00 GiB
  Current LE             5119
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

```


假设要扩充`/dev/myvg/mylv1` 1G则输入命令
```
lvextend -L +1G /dev/myvg/mylv1
```
- 如果扩充100%则输入命令`lvextend -l +100%FREE /dev/myvg/mylv1`

此时我们通过`lvs`查看的大小已经被扩展到了1.5G, 但是此时文件系统仍然是512M，这是因为操作了逻辑空间大小后，需要更新底层的文件系统才能扫描到更新后的逻辑卷

![](Pasted%20image%2020240130151443.png)


### 更新文件系统
```
resize2fs /dev/myvg/mylv1
```


### 查看结果`df -h`
可以看到myvg-my/lv1已经被扩容到了1.5G
```
root@ubuntu22lts:~# df -h
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              388M  1.7M  387M   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv   19G  8.7G  9.0G  49% /
tmpfs                              1.9G     0  1.9G   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda2                          2.0G  251M  1.6G  14% /boot
tmpfs                              388M  4.0K  388M   1% /run/user/0
/dev/mapper/myvg-mylv1             1.5G   24K  1.4G   1% /mnt

```


## 卷组VG的扩容
逻辑卷LV是从卷组VG中获取的，那么VG不够了怎么办？实际上VG也是可以扩容的，前面提到过VG由PE组成，PE是从物理磁盘创建的物理卷PV上分配而来，如果VG不够了，则从PV上分配更多的PE即可。

- 通过vgdisplay的Cur PV可以看到当前卷组挂了几个PV
```
root@ubuntu22lts:~# vgdisplay myvg
  --- Volume group ---
  VG Name               myvg
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               2.99 GiB
  PE Size               4.00 MiB
  Total PE              766
  Alloc PE / Size       384 / 1.50 GiB
  Free  PE / Size       382 / 1.49 GiB
  VG UUID               2v2iHd-jcx3-UWU3-8KIk-wmHe-wEb3-GCpJrS

```
显然，myvg挂了2个PV，通过pvs命令可以看到分别挂了哪些PV
```
root@ubuntu22lts:~#  pvs
  PV         VG        Fmt  Attr PSize    PFree 
  /dev/sda3  ubuntu-vg lvm2 a--   <38.00g 18.00g
  /dev/sdc   myvg      lvm2 a--  1020.00m     0 
  /dev/sdd   myvg      lvm2 a--    <2.00g  1.49g
```
此处可以看到myvg挂了`/dev/sdc`和`/dev/sdd`，此时插入一块新的磁盘/dev/sde，注意虚拟机添加磁盘后要重启才能识别
![](Pasted%20image%2020240130153247.png)

重启后
![](Pasted%20image%2020240130154107.png)

下面是将/dev/sde加入到myvg的过程。
### 创建PV
```
pvcreate /dev/sde
```

### 将新的PV添加到指定卷组中
```
vgextend myvg /dev/sde
```

### 查看扩充后的VG信息

![](Pasted%20image%2020240130154303.png)



## 参考：
- （推荐）1h的LVM视频教程： https://www.bilibili.com/video/BV16W411t7YY?p=2&vd_source=cdd8cee3d9edbcdd99486a833d261c72
	- P1: LVM原理
	- P2: LVM增删
	- P3: LVM扩容
	