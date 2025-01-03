---
date: 2024-02-21T00:10:40+08:00
lastmod: 2024-12-31T03:39:10+08:00
categories:
  - 玩机
  - 路由器
title: RAX3000M搞机目录
draft: "false"
tags:
  - RAX3000M
  - openwrt
  - immortalwrt
  - uboot
  - lede
  - 路由器
series: 
description: RAX3000M EMMC 1214版本开启ssh刷入uboot教程
---
> 注意：这是EMMC版本，NAND版本有一些步骤可以参考，但涉及到存储擦写操作请谨慎！！ EMMC 和 NAND的开启ssh步骤完全相同，都是导出配置->解密->修改配置->加密->导入配置

刷机整体步骤：开启ssh ->  刷uboot -> 进入uboot刷固件 ->  结束
## 如何判断自己是EMMC还是NAND
- 网上主流的说法是看路由器后面的标签来区分，找到路由器后面标签偏上的"制造商“，找到上面的字母CH：
	- NAND： 只有CH
	- EMMC：CH后面还跟着EC
- 但是这种方法不是绝对的，判断的唯一标准是开启ssh后，输入`df -h`命令查看你存储空间的大小，如果有一个50多G的分区，则说明是EMMC，否则是NAND
> 注意，此方法仅针对于出厂固件，有些已经刷过机的固件，可能改过分区表，导致有些空闲空间无法显示。请自行安装 fdisk 判断
## 开启SSH

原理是通过修改配置的方式来开启ssh，由于后面生产的固件，配置文件可能会被加密，因此我们需要解密后才能修改配置文件，然后按照同样的加密方式生成新的配置文件。

> 注意：不要随便导入别人的配置文件，有的人版本和你不一样，导入了可能出错！最好就是自己导出配置文件，自己修改，自己打包再导入

- 参考1： https://blog.csdn.net/weixin_45357522/article/details/135342315
- 参考2： https://blog.iplayloli.com/rax3000m-router-flashing-explanation-nanny-tutorial-easy-to-get-started.html


### 开启ssh流程图
![](IMG_1238(20240328-090533).png)
### 导出配置
配置管理->导出配置文件
### 解密
正常解密后你会获得一个etc目录，里面有路由器的配置文件
```
openssl aes-256-cbc -d -pbkdf2 -k $CmDc#RaX30O0M@\!$ -in cfg_export_config_file.conf -out - | tar -zxvf -
```


> 如果你是6月份生产的，解密可能会报错，因为早期的版本是没有对配置文件进行加密的。
```
bad magic number

gzip: stdin: unexpected end of file
tar: Child returned status 1
tar: Error is not recoverable: exiting now
```

对于这种未加密的配置，可以直接使用`tar -xvzf`解压就可以得到配置文件
```
tar -xvzf cfg_export_config_file.conf 
```

### 修改配置
1. 修改/etc/shadow，去掉root用户的密码，这样ssh进入系统时，不用root密码了。具体做法是： 将两个冒号间的密码删除然后保存
![](Pasted%20image%2020240223141934.png)
2. 修改/etc/config/dropbear开启ssh服务
![](Pasted%20image%2020240223142007.png)

### 加密
> 注意：如果你的配置文件是通过openssl解密得到的（例如1214版本），则需要重新加密后才能导入。

需要openssl加密的版本（1214生产）：
```
tar -zcvf - etc | openssl aes-256-cbc -pbkdf2 -k $CmDc#RaX30O0M@\!$ -out cfg_export_config_file_new.conf
```

不需要加密的版本(6月份生产)
```
tar -zcvf  cfg_export_config_file_new.conf etc
```

### 导入配置
配置管理->导入配置文件，选择我们刚修改好的`cfg_export_config_file_new.conf`，重启后就能使用root用户通过ssh访问了，无需密码。
### 进入ssh备份

- 参考： https://www.right.com.cn/forum/thread-8306986-1-1.html

```
dd if=/dev/mmcblk0p1 of=/mnt/mmcblk0p12/mmcblk0p1.bin

dd if=/dev/mmcblk0p2 of=/mnt/mmcblk0p12/mmcblk0p2.bin

dd if=/dev/mmcblk0p3 of=/mnt/mmcblk0p12/mmcblk0p3.bin

dd if=/dev/mmcblk0p4 of=/mnt/mmcblk0p12/mmcblk0p4.bin

dd if=/dev/mmcblk0p5 of=/mnt/mmcblk0p12/mmcblk0p5.bin

dd if=/dev/mmcblk0p6 of=/mnt/mmcblk0p12/mmcblk0p6.bin

dd if=/dev/mmcblk0p7 of=/mnt/mmcblk0p12/mmcblk0p7.bin

dd if=/dev/mmcblk0p8 of=/mnt/mmcblk0p12/mmcblk0p8.bin

dd if=/dev/mmcblk0p9 of=/mnt/mmcblk0p12/mmcblk0p9.bin

dd if=/dev/mmcblk0p10 of=/mnt/mmcblk0p12/mmcblk0p10.bin

dd if=/dev/mmcblk0p11 of=/mnt/mmcblk0p12/mmcblk0p11.bin
```

然后你可以通过winscp连接上路由器，进入/mnt/mmcblk0p12下载这些备份文件到电脑以防变砖的时候恢复。


## 刷入uboot
uboot是用来刷入固件的，如果你uboot都刷错了那路由器就成砖了，因此以下步骤需要谨慎！网上有很多人用mtd命令刷uboot，但是我手上这台机器则报错

```
Could not open mtd device: /dev/mtd0  
Can't open device for writing
```
### 方法1：hanwckf的uboot
缺点：无法刷入稍微大一点的固件，原因是没有更新分区表。由于没有找到于hanwckf的uboot相关的刷分区表命令，不敢乱刷分区表，而是仅仅更新了uboot。
- 下载链接： https://github.com/hanwckf/bl-mt798x/releases/tag/20240123
- 检查md5，确保文件一致

```
root@RAX3000M:/tmp# md5sum mt7981_cmcc_rax3000m-emmc-fip.bin 
2deacf30fe9cb6ef8a0ce646f507bfb4  mt7981_cmcc_rax3000m-emmc-fip.bin
```

- 刷入uboot命令
> 请注意，下面命令是刷入的emmc版本的uboot，nand版本请不要乱刷！此步刷错必成砖！

```
root@RAX3000M:/tmp# dd if=/tmp/mt7981_cmcc_rax3000m-emmc-fip.bin of=/dev/mmcblk0p3
1148+1 records in
1148+1 records out
root@RAX3000M:/tmp# sync
```

> 请注意，输入以上命令后，请仔细对比结果是否一致，如果不一致，先不要重启，不要重启！保留错误信息，立即寻求帮助！QQ群：514064260

- 进入uboot
	- 断开电源，按住reset不要松开，插上电源，等待红灯亮起后，再松开复位键
	- 路由器的LAN口连接电脑
	- 电脑修改IP地址为192.168.1.2， 默认网关192.168.1.1
	- 浏览器打开192.168.1.1


### 方法2：immortalwrt的uboot(推荐)
> 不是说immortalwrt的uboot只能刷immortalwrt的刷机包，这个uboot可以刷大部分的`.bin`格式的刷机包，例如lede的固件也是可以刷的，其他的刷机包自行测试。

- 参考： openwrt RAX3000M官方教程 https://github.com/openwrt/openwrt/pull/13513
- 参考： immortalwrt刷入教程
	- https://github.com/AngelaCooljx/Actions-rax3000m-emmc
	- https://www.right.com.cn/forum/thread-8306986-1-1.html
- uboot地址：[Developer drive of ImmortalWrt - /uboot/mediatek](https://firmware.download.immortalwrt.eu.org/uboot/mediatek)
- 备用地址： https://wwi.lanzoup.com/iW3FT1pj2mpa
- （没刷过这个链接的）immortalwrt官网连接：[Index of /releases/23.05.0/targets/mediatek/filogic/ (immortalwrt.org)](https://downloads.immortalwrt.org/releases/23.05.0/targets/mediatek/filogic/)


#### 下载uboot
下载后，把uboot上传到路由器的`/tmp/uboot`目录下，ssh进去后，执行`cd /tmp/uboot`该目录，对三个文件分别输入输入`md5sum xxx.bin`确保文件的md5一致，以免刷入损坏的文件，如果md5不一致，请停止操作，重新下载

```
md5sum mt7981-cmcc_rax3000m-emmc-gpt.bin 
md5sum mt7981-cmcc_rax3000m-emmc-bl2.bin 
md5sum mt7981-cmcc_rax3000m-emmc-fip.bin 
```

对比你的md5结果是否和以下结果相同
```
e6ceec4b9d3e86ef538c8b45c1b6ffed  mt7981-cmcc_rax3000m-emmc-gpt.bin

5b061eed5827146b0a14b774c3c57ab2  mt7981-cmcc_rax3000m-emmc-bl2.bin

f1e0b2f1618857ad4e76c8e1b91e7214  mt7981-cmcc_rax3000m-emmc-fip.bin
```

#### 刷入uboot
> 请注意，下面命令是刷入的emmc版本的uboot，nand版本请不要乱刷！此步刷错必成砖！

```
dd if=mt7981-cmcc_rax3000m-emmc-gpt.bin of=/dev/mmcblk0 bs=512 seek=0 count=34 conv=fsync
echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/dev/zero of=/dev/mmcblk0boot0 bs=512 count=8192 conv=fsync
dd if=mt7981-cmcc_rax3000m-emmc-bl2.bin of=/dev/mmcblk0boot0 bs=512 conv=fsync
dd if=/dev/zero of=/dev/mmcblk0 bs=512 seek=13312 count=8192 conv=fsync
dd if=mt7981-cmcc_rax3000m-emmc-fip.bin of=/dev/mmcblk0 bs=512 seek=13312 conv=fsync
```

> 请注意，输入以上命令后，请仔细对比结果是否和下面图片一致，如果不一致，先不要重启，不要重启！保留错误信息，立即寻求帮助！QQ群：514064260

![](Pasted%20image%2020240313144047.png)

查看分区情况。
```
parted /dev/mmcblk0 print
```
如果没有parted命令，则先安装
```
opkg update
opkg install parted
```

分区前，可以看到rootfs大小是64M，而且有2个rootfs，这个空间决定了你刷机包上限的大小
![](Pasted%20image%2020240228001211.png)

分区后，就只有一个rootfs了，大小变成了629M
![](Pasted%20image%2020240228001249.png)

进入uboot方式和方法1一样。

> parted命令报错不要紧，只要刷uboot的命令和结果正确了，就可以按步骤进入uboot刷固件，到时候再安装parted命令查看分区结果。



#### 解释 `dd if=mt7981-cmcc_rax3000m-emmc-gpt.bin of=/dev/mmcblk0 bs=512 seek=0 count=34 conv=fsync`

该命令执行了使用`dd`这一Unix和类Unix操作系统中的常用命令，进行磁盘写入操作。下面将一一解释命令中的每个组件：

- `dd`：这是一个用于转换和复制文件的程序，通常被用于处理磁盘镜像文件或创建备份。
- `if=mt7981-cmcc_rax3000m-emmc-gpt.bin`：`if`代表输入文件（input file），这里指定了要被复制到目的设备上的源文件`mt7981-cmcc_rax3000m-emmc-gpt.bin`。
- `of=/dev/mmcblk0`：`of`代表输出文件（output file），指定了目的地设备。`/dev/mmcblk0`通常表示Linux环境下的第一个MMC设备（比如一个内嵌的eMMC存储）。
- `bs=512`：`bs`代表块大小（blocksize），指定了读取和写入时每个块的大小，这里设置为512字节。每次读取和写入操作处理的数据量是512字节。
- `seek=0`：这一参数指定了在开始写入前应该跳过目的文件（`of`指定的设备）开始的多少个`bs`大小的块。`seek=0`表示不跳过，直接从开头开始写入。
- `count=34`：这一参数指定了要复制的块数量。结合上面的`bs`参数，这意味着此命令将写入34 * 512 = 17408字节的数据。
- `conv=fsync`：`conv`代表转换，`fsync`意味着写入每个块后，`dd`命令会使用`fsync()`系统调用，确保将缓存中的数据立刻刷写到磁盘中。

总结起来，这个`dd`命令的作用是将名为`mt7981-cmcc_rax3000m-emmc-gpt.bin`的文件的前17408字节拷贝到设备`/dev/mmcblk0`，这通常是为了写入一个特定的磁盘镜像或是引导记录等重要数据到一个存储设备上。

#### 解释 `echo 0 > /sys/block/mmcblk0boot0/force_ro`
这条命令在Linux系统中用来修改内核系统参数或者某些设备的设置。具体来说，此命令的各部分含义如下：

- `echo`：是一个常用的shell命令，用于在屏幕上显示一段文字，或者将文字写入到文件中。
- `0`：这是`echo`命令输出的内容。在这个上下文中，数字`0`通常被用来表示禁用或关闭一个选项。
- `>`：这是重定向操作符。它会将左侧命令的输出（在这个例子中是`echo`命令的输出）重定向到右侧指定的文件或设备。
- `/sys/block/mmcblk0boot0/force_ro`：这是一个路径，指向sysfs（一种虚拟文件系统）中的一个文件。在Linux中，sysfs用于导出内核对象的信息，允许运行中的系统通过用户空间的变化影响内核。`mmcblk0boot0`指的是一个特定的eMMC存储设备的引导分区，而`force_ro`文件允许用户将该分区设置为只读(`ro`)或可读写模式。

所以，当执行`echo 0 > /sys/block/mmcblk0boot0/force_ro`命令时，它实际上是在将数字`0`写入到`force_ro`文件。这个操作会告诉系统不要强制将`mmcblk0boot0`这个eMMC引导分区设为只读模式，这允许在需要的时候对其进行修改。这种修改可能是为了更新引导加载程序或者对引导分区进行其他形式的写入操作。


#### 解释 `dd if=/dev/zero of=/dev/mmcblk0boot0 bs=512 count=8192 conv=fsync`
这条 `dd` 命令用于将数据写入Linux系统中的存储设备，命令各部分具体解释如下：

- `dd` 是“data duplicator”的缩写，是一个非常强大的Unix命令行工具，用于转换和复制文件或设备内容。
- `if=/dev/zero` 中的 `if` 代表输入文件（input file）。`/dev/zero` 是一个特殊的文件，它会不断提供无限的零（0x00）值。相当于输入源是「无限的0」。
- `of=/dev/mmcblk0boot0` 中的 `of` 指输出文件（output file），在这里表示要写入的目标设备。`/dev/mmcblk0boot0` 可能是系统中某个eMMC存储设备的引导分区。
- `bs=512` 中的 `bs` 表示块大小（block size），单位是字节。每次读取和写入操作会处理512字节的数据。
- `count=8192` 这部分指明了要复制的块的数量，与`bs`结合，意味着命令会写入 `8192 * 512 = 4194304` 字节，即4MB的数据。
- `conv=fsync` 指的是在写入每个块后，强制直接将内存中的缓冲数据同步到硬盘上，确保所有数据正确的被写入到设备中。

整个命令的作用是，向`/dev/mmcblk0boot0`这个eMMC存储设备的引导分区写入4MB的全零数据，这通常会将该**存储区域清除**。这种操作常用于清理分区的内容，以便重新格式化或重新使用存储区域。

> 进入uboot方式和方法1

### 方法3： openwrt官网uboot
- 参考： https://github.com/openwrt/openwrt/pull/13513#issue-1909808957
- uboot来源：官网下载或者自己编译固件时会生成。

- 官网的uboot不带web界面，只能刷入`.itb`格式的固件，和第三方uboot不兼容
- 如果希望修改root分区大小，请在编译镜像时候在Target Images -> Root filesystem 处修改，每次修改大小都要重新刷GPT，否则不生效。

>  请注意，下面命令是刷入的emmc版本的uboot，nand版本请不要乱刷！此步刷错必成砖！

1. 刷入GPT分区（从0~17408）
```
dd if=openwrt-mediatek-filogic-cmcc_rax3000m-emmc-gpt.bin of=/dev/mmcblk0 bs=512 seek=0 count=34 conv=fsync
```
2. 擦写bl2分区
```
echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/dev/zero of=/dev/mmcblk0boot0 bs=512 count=8192 conv=fsync
dd if=openwrt-mediatek-filogic-cmcc_rax3000m-emmc-preloader.bin of=/dev/mmcblk0boot0 bs=512 conv=fsync
```

3. 写入新的uboot
```
dd if=/dev/zero of=/dev/mmcblk0 bs=512 seek=13312 count=8192 conv=fsync
dd if=openwrt-mediatek-filogic-cmcc_rax3000m-emmc-bl31-uboot.fip of=/dev/mmcblk0 bs=512 seek=13312 conv=fsync
```

![](Pasted%20image%2020240228175932.png)

> 请注意，输入以上命令后，请仔细对比结果是否和下面图片一致，如果不一致，先不要重启，不要重启！保留错误信息，立即寻求帮助！QQ群：514064260

![](Pasted%20image%2020240228182730.png)

## 刷入openwrt
自用固件： https://www.right.com.cn/forum/thread-8349807-1-1.html

#### 参考：
- 官网教程： https://openwrt.org/docs/guide-user/installation/generic.flashing.tftp
- 油管教程： https://www.youtube.com/watch?v=7UIX9v2oV58
- 教程： https://www.1234f.com/sj/technique/xxzl/20231108/560.html
- 视频教程： https://www.bilibili.com/video/BV1dj411b7yW/?spm_id_from=333.337.search-card.all.click&vd_source=cdd8cee3d9edbcdd99486a833d261c72
### 官方openwrt
> 注意：官方版本的固件只能由官方的uboot刷入，和第三方固件不兼容。

- 参考： itb 格式怎么刷？ https://www.right.com.cn/forum/thread-8316238-1-1.html

#### 重启路由器
刷入openwrt的官方uboot后，只需要断开电源，按住reset再插上电源重启即可，路由器会等待tftp服务器上传固件。

#### 设置电脑IP地址
- 设置静态地址 192.168.1.254（注意，一定是1.254而不是别的ip地址）
- 网关和DNS填入192.168.1.1

此时电脑网线连接路由器的LAN口，打开powershell输入`ping 192.168.1.1` 应当有回应，否则表明你路由器没有成功连接电脑或者路由器没有进入uboot模式

```
Pinging 192.168.1.1 with 32 bytes of data:  
Reply from 192.168.1.1: bytes=32 time<1ms TTL=64  
Reply from 192.168.1.1: bytes=32 time<1ms TTL=64  
Reply from 192.168.1.1: bytes=32 time<1ms TTL=64  
Reply from 192.168.1.1: bytes=32 time<1ms TTL=64
```

#### 打开[tftp服务器](https://pjo2.github.io/tftpd64/)
把`openwrt-mediatek-filogic-cmcc_rax3000m-initramfs-recovery.itb` 格式文件放在和tftp服务器相同的目录。如果不是这个名称，手动修改一下。过一会就会自动上传固件了。

![](Pasted%20image%2020240228184200.png)

#### 进入路由器后台
点击`转到固件升级`
![](Pasted%20image%2020240228183956.png)

选择`openwrt-mediatek-filogic-cmcc_rax3000m-squashfs-sysupgrade.itb` 上传升级
![](Pasted%20image%2020240228184954.png)

刷完之后会重启一次，如果发现仍然在 initramfs恢复系统模式，则点击`系统`->`重启` -> `执行重启`即可

23.05.2 一些使用的问题和解决方案-> [index.zh-cn](../RAX3000M使用官方OpenWRT的23.05.2一些问题以及解决方案/index.zh-cn.md)

### lede
进uboot刷即可，但是hanwckf的uboot无法刷入稍微大一点的固件（70M左右），40兆左右的固件则可以刷入，是因为刷h大的uboot步骤没有更新分区表，导致了分配给刷固件的空间有限。因此建议刷immortal的uboot。



### immortalwrt
直接进uboot刷即可.

- 镜像和刷入教程： [AngelaCooljx/Actions-rax3000m-emmc: Build ImmortalWrt for CMCC RAX3000M eMMC version using GitHub Actions](https://github.com/AngelaCooljx/Actions-rax3000m-emmc)



## 利用剩余的内存

### 分区

刷好固件后，发现有50多G的空间不见了，这是因为分区表变了，有一部分空闲空间未分配，你可以通过cfdisk命令创建新分区。
```
opkg update
opkg install cfdisk
```

创建分区
```
cfdisk /dev/mmcblk0
```
找到最下面的Fress Space，选择New
![](Pasted%20image%2020240302150128.png)
会自动分配最大内存，然后回车
![](Pasted%20image%2020240302150153.png)

则创建了一个56.9G大小的新分区，光标移动到Write
![](Pasted%20image%2020240302150316.png)
然后输入yes，回车，然后键盘按下`q`退出
![](Pasted%20image%2020240302150402.png)


### 格式化
安装`mkfs.ext4`命令包
```
 opkg install e2fsprogs
```
格式化我们新创建的分区
```
mkfs.ext4 /dev/mmcblk0p7
```

### 挂载
> 如果你的固件安装了automount，后面的挂载步骤都不需要看了。过一会就会自动挂载了，没有挂载则重启后再试试。安装方法是去`系统`-> `软件包`，点击更新软件列表，然后搜索`automount`点击安装。

首先检查是不是被自动挂载了，输入`lsblk`，在`NAME`列找到刚刚创建并格式化的分区，这里对应的是`mmcblk0p7`，对应的`MOUNTPOINTS`那一列如果为空，表示尚未挂载。比如下面的命令表示mmcblk0p7还没有挂载。
```
root@ImmortalWrt:~# lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 471.3M  0 loop /overlay
sda            8:0    0 238.5G  0 disk 
└─sda1         8:1    0 238.5G  0 part /mnt/sda1
mmcblk0      179:0    0  57.6G  0 disk 
├─mmcblk0p1  179:1    0   512K  0 part 
├─mmcblk0p2  179:2    0     2M  0 part 
├─mmcblk0p3  179:3    0     4M  0 part 
├─mmcblk0p4  179:4    0    20M  0 part 
├─mmcblk0p5  179:5    0    64M  0 part 
├─mmcblk0p6  179:6    0   600M  0 part /rom
└─mmcblk0p7  179:7    0  56.9G  0 part 
mmcblk0boot0 179:8    0     4M  1 disk 
mmcblk0boot1 179:16   0     4M  1 disk
```
如果你没有lsblk命令，也可以用`df -h`或者`mount`命令检查。
```
root@ImmortalWrt:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root               128.8M    128.8M         0 100% /rom
tmpfs                   240.6M     10.0M    230.6M   4% /tmp
/dev/loop0              469.3M     81.8M    387.5M  17% /overlay
overlayfs:/overlay      469.3M     81.8M    387.5M  17% /
tmpfs                   512.0K         0    512.0K   0% /dev
/dev/sda1               234.5G     11.5G    211.1G   5% /mnt/sda1
```
df命令的输出中没有找到`mmcblk0p7`，说明没挂载，mount命令同理。
```
root@ImmortalWrt:~# mount
/dev/root on /rom type squashfs (ro,relatime,errors=continue)
proc on /proc type proc (rw,nosuid,nodev,noexec,noatime)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,noatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noatime)
/dev/loop0 on /overlay type f2fs (rw,lazytime,noatime,background_gc=on,nodiscard,no_heap,user_xattr,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=reuse,checkpoint_merge,fsync_mode=posix,discard_unit=block)
overlayfs:/overlay on / type overlay (rw,noatime,lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work,xino=off)
tmpfs on /dev type tmpfs (rw,nosuid,noexec,noatime,size=512k,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,noatime,mode=600,ptmxmode=000)
debugfs on /sys/kernel/debug type debugfs (rw,noatime)
bpffs on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,noatime,mode=700)
pstore on /sys/fs/pstore type pstore (rw,noatime)
/dev/sda1 on /mnt/sda1 type ext4 (rw,relatime)
```


尝试手动挂载到指定目录，例如我想挂载到`/mnt/mmcblk0p7`，则需要先创建该文件夹。你想挂载到什么目录都可以，前提是需要创建该挂载路径。
```
mkdir /mnt/mmcblk0p7
```

执行手动挂载命令，命令格式：  `mount  设备  路径`，例如把`/dev/mmcblk0p7`挂载到 `/mnt/mmcblk0p7`的命令如下
```
mount /dev/mmcblk0p7 /mnt/mmcblk0p7
```

然后再输入`lsblk`检查，可以看到`NAME`列中的`mmcblk0p7`，其对应的`MOUNTPOINTS`列多了一行路径
```
root@ImmortalWrt:~# lsblk
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0          7:0    0 471.3M  0 loop /overlay
sda            8:0    0 238.5G  0 disk 
└─sda1         8:1    0 238.5G  0 part /mnt/sda1
mmcblk0      179:0    0  57.6G  0 disk 
├─mmcblk0p1  179:1    0   512K  0 part 
├─mmcblk0p2  179:2    0     2M  0 part 
├─mmcblk0p3  179:3    0     4M  0 part 
├─mmcblk0p4  179:4    0    20M  0 part 
├─mmcblk0p5  179:5    0    64M  0 part 
├─mmcblk0p6  179:6    0   600M  0 part /rom
└─mmcblk0p7  179:7    0  56.9G  0 part /mnt/mmcblk0p7
mmcblk0boot0 179:8    0     4M  1 disk 
mmcblk0boot1 179:16   0     4M  1 disk 
```
df命令检查，可以看到最后一行的Filesystem列多了`/dev/mmcblk0p7`，后面的Mounted on表示挂载到的路径
```
root@ImmortalWrt:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root               128.8M    128.8M         0 100% /rom
tmpfs                   240.6M     10.1M    230.6M   4% /tmp
/dev/loop0              469.3M     81.8M    387.5M  17% /overlay
overlayfs:/overlay      469.3M     81.8M    387.5M  17% /
tmpfs                   512.0K         0    512.0K   0% /dev
/dev/sda1               234.5G     11.5G    211.1G   5% /mnt/sda1
/dev/mmcblk0p7           55.7G    601.0M     52.3G   1% /mnt/mmcblk0p7
```

mount命令检查，可以看到最后一列 `/dev/mmcblk0p7 on /mnt/mmcblk0p7`
```
root@ImmortalWrt:~# mount
/dev/root on /rom type squashfs (ro,relatime,errors=continue)
proc on /proc type proc (rw,nosuid,nodev,noexec,noatime)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,noatime)
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noatime)
/dev/loop0 on /overlay type f2fs (rw,lazytime,noatime,background_gc=on,nodiscard,no_heap,user_xattr,inline_xattr,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,alloc_mode=reuse,checkpoint_merge,fsync_mode=posix,discard_unit=block)
overlayfs:/overlay on / type overlay (rw,noatime,lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work,xino=off)
tmpfs on /dev type tmpfs (rw,nosuid,noexec,noatime,size=512k,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,noatime,mode=600,ptmxmode=000)
debugfs on /sys/kernel/debug type debugfs (rw,noatime)
bpffs on /sys/fs/bpf type bpf (rw,nosuid,nodev,noexec,noatime,mode=700)
pstore on /sys/fs/pstore type pstore (rw,noatime)
/dev/sda1 on /mnt/sda1 type ext4 (rw,relatime)
/dev/mmcblk0p7 on /mnt/mmcblk0p7 type ext4 (rw,relatime)
```


这种手动挂载的方式会在每次重启后失效。这里挂载的目的是为了测试该分区是否能成功挂载，为了让重启也生效，我们需要借助一些自动挂载的工具。

- 工具1：在系统->软件包，先更新软件列表，然后搜索automount并安装， 一般来说固件如果装了automount会自动挂载，装好后没有自动挂载重启一下试试。
- 工具2：web界面找到挂载点挂载即可，但是这种挂载方式有时候会抽风，不知道为什么

## 插件下载地址
有些插件依赖安装比较麻烦，不一定都能安装上。
- github地址: [kenzok8/openwrt-packages: openwrt常用软件包 (github.com)](https://github.com/kenzok8/openwrt-packages)
- ipk地址： [OpenWrt固件与插件 (dllkids.xyz)](https://op.dllkids.xyz/packages/aarch64_cortex-a53/)



## 如何手动[安装docker](https://docs.docker.com/engine/install/binaries/#install-daemon-and-client-binaries-on-linux)到移动硬盘
> 如果你是emmc，或者nand经过了扩容，建议直接安装luci-app-dockerman，而不是手动安装docker二进制文件

- 测试环境：ImmortalWRT 23.05.1 
### 官网对系统的要求
- 64位系统
- Linux内核版本>=3.10 
- `iptables` version 1.4 or higher（实际上也可以用nftables）
- `git` 版本>=1.7 
-  `ps` 命令可用, 通常由`procps`包提供
- [XZ Utils](https://tukaani.org/xz/) >= 4.9 (啥来的)
- A [properly mounted](https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount) `cgroupfs` hierarchy; a single, all-encompassing `cgroup` mount point is not sufficient. See Github issues [#2683](https://github.com/moby/moby/issues/2683), [#3485](https://github.com/moby/moby/issues/3485), [#4568](https://github.com/moby/moby/issues/4568)). (没看懂)

> 移动硬盘请格式化为ext4格式，不要ntfs，对Linux兼容性不好，不建议使用u盘，速度太慢，影响docker运行效率。

### 下载[docker二进制文件](https://download.docker.com/linux/static/stable/aarch64/)

假设移动硬盘挂载到了`/mnt/sda1`, 这里创建一个名称为`rax3000m_docker`的目录
```
mkdir -p /mnt/sda1/rax3000m_docker
cd /mnt/sda1/rax3000m_docker
```
下载docker二进制文件（这种下载方式巨慢，不如手动下载后放进u盘）
```
wget https://download.docker.com/linux/static/stable/aarch64/docker-25.0.4.tgz
```
假如下载中途断掉了，文件可能会损坏，因此需要确认一下md5是否一致，以保证文件的完整性
```
md5sum docker-25.0.4.tgz 
9095035fc0700aacfc7262cf353e91e8  docker-25.0.4.tgz
```

下载后，使用`tar`命令解压(如果解压失败，那就自己先解压出docker文件夹后放进去)

```
tar -xvzf docker-25.0.4.tgz 
```
解压结果
```
root@ImmortalWrt:/mnt/sda1/rax3000m_docker# tar -xvzf docker-25.0.4.tgz 
docker/
docker/docker
docker/containerd
docker/docker-proxy
docker/ctr
docker/runc
docker/dockerd
docker/containerd-shim-runc-v2
docker/docker-init
```

### 添加环境变量和存储路径
我们把这堆命令放到环境变量，编辑终端的配置文件
```
vi /etc/profile
```
添加一行
```
export PATH=$PATH:/mnt/sda1/rax3000m_docker/docker
```

保存后，执行以下命令使得当前终端可以使用dockerd命令
```
source /etc/profile
```

创建data-root，镜像文件会下载到这里
```
mkdir -p /mnt/sda1/rax3000m_docker/data-root
```

### 启动docker守护进程
输入`dockerd`启动docker守护进程，发现iptables报错了

```
 error="exec: \"iptables\": executable file not found in $PATH"
```
 则指定禁用iptables即可
- docker命令行参考 https://docs.docker.com/reference/cli/dockerd/
- 配置参考 https://docs.docker.com/config/daemon/
```
dockerd --iptables=false --data-root=/mnt/sda1/rax3000m_docker/data-root
```
启动成功，此时守护进程开启，按下Ctrl+C或者关掉终端，则会关闭守护进程
```
... 省略部分日志
INFO[2024-03-09T13:13:43.881084973Z] containerd successfully booted in 0.163237s  
INFO[2024-03-09T13:13:44.719192506Z] [graphdriver] using prior storage driver: overlay2 
INFO[2024-03-09T13:13:44.722489900Z] Loading containers: start.                   
WARN[2024-03-09T13:13:44.733961421Z] Could not load necessary modules for IPSEC rules: protocol not supported 
INFO[2024-03-09T13:13:44.814235829Z] Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address 
INFO[2024-03-09T13:13:44.822904807Z] Loading containers: done.                    
WARN[2024-03-09T13:13:44.848897662Z] WARNING: No swap limit support               
WARN[2024-03-09T13:13:44.848993985Z] WARNING: bridge-nf-call-iptables is disabled 
WARN[2024-03-09T13:13:44.849033838Z] WARNING: bridge-nf-call-ip6tables is disabled 
INFO[2024-03-09T13:13:44.849138009Z] Docker daemon                                 commit=061aa95 containerd-snapshotter=false storage-driver=overlay2 version=25.0.4
INFO[2024-03-09T13:13:44.849459217Z] Daemon has completed initialization          
INFO[2024-03-09T13:13:44.980870194Z] API listen on /var/run/docker.sock   
```
如果要后台运行守护进程，则在命令后面加上`&`符号
```
dockerd --iptables=false --data-root=/mnt/sda1/rax3000m_docker/data-root &
```



### 测试运行镜像
打开新的终端（注意别把守护进程关了）测试一下镜像
```
docker run --rm hello-world
```
报错了
```
root@ImmortalWrt:/mnt/sda1/# docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
478afc919002: Pull complete 
Digest: sha256:d000bc569937abbe195e20322a0bde6b2922d805332fd6d8a68b19f524b7d21d
Status: Downloaded newer image for hello-world:latest
docker: Error response from daemon: failed to create endpoint inspiring_napier on network bridge: failed to add the host (vethcf82129) <=> sandbox (vethde4930e) pair interfaces: operation not supported.
```

加上参数`--net=host`把网络模式改为host模式即可
> 24版本的docker有bug，必须使用host网络，否则无法访问
```
root@ImmortalWrt:/mnt/sda1/# docker run --rm --net=host hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```





## 扩容overlays（emmc没必要）
- 参考： https://www.techkoala.net/openwrt_resize/
> 扩容后，你的系统将和磁盘共存亡，一旦磁盘挂掉，只能重新刷机，请确保磁盘的稳定性，不建议使用机械硬盘。
#### 插入u盘，格式化成ext4
```
mkfs.ext4 /dev/sda1
```

如果没有这个命令，就先安装
```
opkg update
opkg install e2fsprogs
```

如果报错`/dev/sda1 is mounted; will not make a filesystem here!`，说明你u盘被自动挂载了，先取消挂载
```
umount /dev/sda1
```

然后重新执行
```
mkfs.ext4 /dev/sda1
```
他如果问你是否继续，输入y后回车即可。
![](Pasted%20image%2020240302094556.png)
此时u盘成功格式化成ext4格式

### 挂载U盘
创建挂载点
```
mkdir -p /mnt/sda1
```
挂载
```
mount /dev/sda1 /mnt/sda1
```

#### 复制原来的`/overlay/*`到u盘
```
cp -r /overlay/* /mnt/sda1/
```

如果没有/overlay，看看是否在`/rom/overlay`
```
cp -r /rom/overlay/* /mnt/sda1/
```
复制成功后，可以在`/mnt/sda1`看到upper和work文件夹

### 重新挂载u盘到/overlays

取消挂载
```
umount /dev/sda1
```
挂载到/overlay
```
mount /dev/sda1 /overlay
```
挂载前:
![](Pasted%20image%2020240302094803.png)

挂载后
![](Pasted%20image%2020240302095922.png)

### 进入web界面挂载
- 为了让系统自动挂载，可以在web界面设置挂载点，这样重启后仍然保留挂载，如果没有找到`挂载点`，则去软件包那里搜索`block-mount` 安装(注意先更新软件列表)
- 根据uuid选中你的u盘，作为外部overlay使用，然后点击保存&应用即可。
![](Pasted%20image%2020240302103042.png)


## 如何手动安装istore
- 教程： https://github.com/linkease/istore

### 更新仓库
```
opkg update || exit 1
```

### 下载脚本
开科学上网后再下载，否则可能失败。
```
cd /tmp
wget https://github.com/linkease/openwrt-app-actions/raw/main/applications/luci-app-systools/root/usr/share/systools/istore-reinstall.run
```

如果实在下载不了，则手动打开[脚本地址](https://github.com/linkease/openwrt-app-actions/raw/main/applications/luci-app-systools/root/usr/share/systools/istore-reinstall.run)，复制页面的内容新建的文本文档里面

```
vi istore-reinstall.run
```
粘贴页面上的内容到`istore-reinstall.run`，这里我把脚本复制下来了（注意，该脚本可能会随着页面更新而内容不同，请以网站上的内容为准）
```
#!/bin/sh
ISTORE_REPO=https://istore.linkease.com/repo/all/store
FCURL="curl --fail --show-error"

curl -V >/dev/null 2>&1 || {
  echo "prereq: install curl"
  opkg info curl | grep -Fqm1 curl || opkg update
  opkg install curl
}

IPK=`$FCURL "$ISTORE_REPO/Packages.gz" | zcat | grep -m1 '^Filename: luci-app-store.*\.ipk$' | sed -n -e 's/^Filename: \(.\+\)$/\1/p'`

[ -n "$IPK" ] || exit 1

$FCURL "$ISTORE_REPO/$IPK" | tar -xzO ./data.tar.gz | tar -xzO ./bin/is-opkg > /tmp/is-opkg

[ -s "/tmp/is-opkg" ] || exit 1

chmod 755 /tmp/is-opkg
/tmp/is-opkg update
# /tmp/is-opkg install taskd
/tmp/is-opkg opkg install --force-reinstall luci-lib-taskd luci-lib-xterm
/tmp/is-opkg opkg install --force-reinstall luci-app-store || exit $?
[ -s "/etc/init.d/tasks" ] || /tmp/is-opkg opkg install --force-reinstall taskd
[ -s "/usr/lib/lua/luci/cbi.lua" ] || /tmp/is-opkg opkg install luci-compat >/dev/null 2>&1
```


### 执行安装脚本
```
chmod 755 istore-reinstall.run
./istore-reinstall.run
```
成功日志
```
... 省略部分日志
Installing mount-utils (2.39-2) to root...
Downloading https://mirrors.vsean.net/openwrt/releases/23.05.1/packages/aarch64_cortex-a53/base/mount-utils_2.39-2_aarch64_cortex-a53.ipk
Configuring libuci-lua.
Configuring libbz2-1.0.
Configuring liblzma.
Configuring coreutils-stat.
Configuring bzip2.
Configuring xz-utils.
Configuring xz.
Configuring tar.
Configuring mount-utils.
Configuring luci-app-store.
root@ImmortalWrt:/mnt/sda1# 
```
此时打开路由器后台web界面可以看到多了个istore选项栏.
> 注意：istore有些插件依赖docker，对于24版本的docker请勾选上host network，否则会无法访问


## ipv6中继
- 教程： https://www.right.com.cn/forum/thread-8309440-1-1.html
- 往期文章-> [index.zh-cn](../RAX3000M-openwrt使用ipv6中继/index.zh-cn.md)
## openclash
如果发现无法启动openclash，可能缺少内核clash，需要安装。
### 安装内核方法
#### 方法1: 修改github地址
覆写设置->修改github地址，随便选一个，然后点击启动openclash会自动下载安装

#### 方法2: [手动下载](https://github.com/vernesong/OpenClash/releases/tag/Clash)并上传到路由器

RAX3000M选择[clash-linux-armv8.tar.gz](https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv8.tar.gz)，解压后，上传到`/etc/openclash/core/`目录下，给予执行权限
```
chmod +x /etc/openclash/core/clash
```

有时候你会发现你自己没上传，但是这个目录里面已经有了clash文件，而web界面仍然启动失败，可能因为这个文件是损坏的，验证方法就是手动执行一下 `./clash -v`
正常结果是
```
root@ImmortalWrt:/etc/openclash/core# ./clash -v
Clash v1.11.0-7-g5497ada linux arm64 with go1.18 2022年 07月 06日 星期三 00:12:50 UTC
```

异常情况 `Bus error`，这时候你就要删掉这个损坏的clash文件，放入自己下载的文件。

### 开启openclash无法登录游戏
- 参考： https://github.com/vernesong/OpenClash/issues/107
- 解决：运行模式使用TUN模式

## USB网络共享(iOS未成功)
参考
-  https://www.cnblogs.com/cogito/p/it_tools16.html
- https://openwrt.org/docs/guide-user/network/wan/smartphone.usb.tethering

### 安装内核模块支持

### USB网络共享-RNDIS协议
```
opkg update
opkg install kmod-usb-net-rndis 
```

### usb驱动
```
opkg update
opkg install kmod-nls-base kmod-usb-core kmod-usb-net kmod-usb-net-cdc-ether kmod-usb2
```


### 手机开启USB网络共享
小米手机：系统设置->更多连接方式->USB网络共享。如果该选项是灰色的，要么是你的线有问题，要么是驱动没安装好，请到官网教程相关信息。

### 网页添加网络设备
![](Pasted%20image%2020240310135720.png)

防火墙分配区域到WAN
![](Pasted%20image%2020240310135749.png)
点击`保存并应用`后，过几秒可以看到设备获取到了ip地址，此时就可以上网了。
![](Pasted%20image%2020240310135844.png)

## 其他问题
### docker程序的端口无法打开
docker 24.0.5版本可能无法正常使用默认的bridge模式，需要切换成host模式，例如alist，官网给出的运行命令是
```
docker run -d --restart=unless-stopped -v /etc/alist:/opt/alist/data -p 5244:5244 -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest
```
会发现打不开 http://192.168.1.1:5244 , 需要手动添加参数 `--network=host` 来使用宿主机模式的网络。
- 注意端口可能会冲突，5244不能被系统提前占用
- 使用host网络模式不再需要指定-p参数。

```
docker run -d --restart=unless-stopped -v /etc/alist:/opt/alist/data --network=host -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest
```


### docker pull提示空间不足
下面方法任意选一种即可，注意先在Docker->概览处停止docker，然后再改配置。改完后再启动docker
#### 方法一：luci界面上修改docker根目录
找到Docker->配置，把Docker根目录改到空间大的目录

![](Pasted%20image%2020240417175133.png)
#### 方法二：直接修改dockerd配置
编辑 `/etc/config/dockerd`，找到`data_root`，修改到空间大的目录
```
config globals 'globals'
        option data_root '/mnt/mmcblk0p7/docker'
        option log_level 'warn'
        option iptables '1'
        option auto_start '1'

config dockerman 'dockerman'
        option socket_path '/var/run/docker.sock'
        option status_path '/tmp/.docker_action_status'
        option debug 'false'
        option debug_path '/tmp/.docker_debug'
        option remote_endpoint '0'
        list ac_allowed_interface 'br-lan'
```

### 方法三：修改dockerd启动参数（仅适合手动下载dockerd运行的用户）
前面我们讲到如何手动安装dockerd，在启动的时候加一个参数`--data-root`即可
```
dockerd --iptables=false --data-root=/mnt/sda1/rax3000m_docker/data-root
```



### istore安装的插件打不开
移除插件，勾选host网络后重新安装


### ntfs无法挂载
- 卸载`ntfs3-mount`，此脚本实际上就是一行代码`mount -t ntfs3 -o iocharset=utf8 "$@"`，和`ntfs-3g-utils`冲突，我们要用到后者
- 又因为`automount`依赖于`ntfs3-mount`，因此也要卸载`automount`，卸载`automount`后连`ext4`也无法自动挂载了。
```
opkg remove automount
opkg remove ntfs3-mount
```
安装`ntfs-3g-utils`
```
opkg update
opkg install ntfs-3g-utils
```
挂载到`/mnt/sda1`
```
mkdir -p /mnt/sda1
ntfs-3g /dev/sda1 /mnt/sda1
```

使用 ntfs-3g 挂载报错
- 参考 https://askubuntu.com/questions/500647/unable-to-mount-ntfs-external-hard-drive
```
Failed to mount '/dev/sda1': I/O error
NTFS is either inconsistent, or there is a hardware fault, or it's a
SoftRAID/FakeRAID hardware. In the first case run chkdsk /f on Windows
then reboot into Windows twice. The usage of the /f parameter is very
important! If the device is a SoftRAID/FakeRAID then first activate
it and mount a different device under the /dev/mapper/ directory, (e.g.
/dev/mapper/nvidia_eahaabcc1). Please see the 'dmraid' documentation

```
解决：使用ntfsfix
```
root@OpenWrt:~# ntfsfix  /dev/sda1
Mounting volume... $MFTMirr does not match $MFT (record 3).
FAILED
Attempting to correct errors... 
Processing $MFT and $MFTMirr...
Reading $MFT... OK
Reading $MFTMirr... OK
Comparing $MFTMirr to $MFT... FAILED
Correcting differences in $MFTMirr record 3...OK
Processing of $MFT and $MFTMirr completed successfully.
Setting required flags on partition... OK
Going to empty the journal ($LogFile)... OK
Checking the alternate boot sector... OK
NTFS volume version is 3.1.

```

然后再次挂载

```
ntfs-3g /dev/sda1 /mnt/sda1
```

仍旧不行，则用电脑使用Diskgenius重新格式化成ntfs。（最好用ext4格式，稳定一点）


### 找不到无线设置选项？
- bug反馈： https://github.com/immortalwrt/immortalwrt/issues/1201
- emmc设备安装了autosamba会出现此bug，删掉它即可。系统->软件包->过滤框输入 autosamba，找到autosamba并删掉。


### samba4网络共享无法访问？
- 参考: https://learn.microsoft.com/zh-cn/troubleshoot/windows-client/networking/cannot-access-shared-folder-file-explorer
- 解决方式： windows同时按下`win` + `r` 两个按键，弹出运行框后输入`gpedit.msc`打开`本地组策略编辑器`，找到`计算机配置`->`管理模板`->`网络` ->`Lanman工作站` ，双击`启用不安全的来宾登录` ，把`未配置`改为`已启用`，最后点击`确定`
