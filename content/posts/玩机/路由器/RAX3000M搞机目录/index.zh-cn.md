---
date: 2024-02-21T00:10:40+08:00
lastmod: 2024-02-25T07:38:50+08:00
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


### 导出配置
配置管理->导出配置文件
### 解密
解密后你会获得一个etc目录，里面有路由器的配置文件
```
openssl aes-256-cbc -d -pbkdf2 -k $CmDc#RaX30O0M@\!$ -in ../cfg_export_config_file.conf -out - | tar -zxvf -
```

### 修改配置
1. 修改/etc/shadow，去掉root用户的密码，这样ssh进入系统时，不用root密码了。具体做法是： 将两个冒号间的密码删除然后保存
![](Pasted%20image%2020240223141934.png)
2. 修改/etc/config/dropbear开启ssh服务
![](Pasted%20image%2020240223142007.png)

### 加密
```
tar -zcvf - etc | openssl aes-256-cbc -pbkdf2 -k $CmDc#RaX30O0M@\!$ -out ../cfg_export_config_file_new.conf
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
### 方法1：h大的uboot
缺点：无法刷入稍微大一点的固件
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

- 进入uboot
	- 断开电源，按住reset不要松开，插上电源，等待红灯亮起后，再松开复位键
	- 路由器的LAN口连接电脑
	- 电脑修改IP地址为192.168.1.2， 默认网关192.168.1.1
	- 浏览器打开192.168.1.1


### 方法2：immortalwrt的uboot
- 参考： openwrt RAX3000M官方教程 https://github.com/openwrt/openwrt/pull/13513
- 参考： immortalwrt刷入教程
	- https://github.com/AngelaCooljx/Actions-rax3000m-emmc
	- https://www.right.com.cn/forum/thread-8306986-1-1.html
- uboot地址：[Developer drive of ImmortalWrt - /uboot/mediatek](https://firmware.download.immortalwrt.eu.org/uboot/mediatek)
- 备用地址： https://wwi.lanzoup.com/iW3FT1pj2mpa
- （没刷过这个链接的）immortalwrt官网连接：[Index of /releases/23.05.0/targets/mediatek/filogic/ (immortalwrt.org)](https://downloads.immortalwrt.org/releases/23.05.0/targets/mediatek/filogic/)

> 请注意，下面命令是刷入的emmc版本的uboot，nand版本请不要乱刷！此步刷错必成砖！

```
dd if=mt7981-cmcc_rax3000m-emmc-gpt.bin of=/dev/mmcblk0 bs=512 seek=0 count=34 conv=fsync
echo 0 > /sys/block/mmcblk0boot0/force_ro
dd if=/dev/zero of=/dev/mmcblk0boot0 bs=512 count=8192 conv=fsync
dd if=mt7981-cmcc_rax3000m-emmc-bl2.bin of=/dev/mmcblk0boot0 bs=512 conv=fsync
dd if=/dev/zero of=/dev/mmcblk0 bs=512 seek=13312 count=8192 conv=fsync
dd if=mt7981-cmcc_rax3000m-emmc-fip.bin of=/dev/mmcblk0 bs=512 seek=13312 conv=fsync
```


![](Pasted%20image%2020240224012602.png)

查看分区情况
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

> 进入uboot方式和方法1相同。


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
进uboot刷即可，但是h大的uboot无法刷入稍微大一点的固件（70M左右），40兆左右的固件则可以刷入，是因为刷h大的uboot步骤没有更新分区表，导致了分配给刷固件的空间有线。因此建议刷immortal的uboot。



### immortalwrt
镜像和刷入教程： [AngelaCooljx/Actions-rax3000m-emmc: Build ImmortalWrt for CMCC RAX3000M eMMC version using GitHub Actions](https://github.com/AngelaCooljx/Actions-rax3000m-emmc)



## 利用剩余的内存

#### 分区

当你刷好固件后，发现有50多G的空间不见了，这是因为分区表变了，你要自己重新分区
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
去web界面找打挂载点挂载即可

## 扩容overlays
- 参考： https://www.techkoala.net/openwrt_resize/

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
```
mount /dev/sda1 /mnt/sda1
```

#### 复制原来的`/overlay/*`到u盘
```
cp -r /overlay/* /mnt/sda1
```


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
- 为了让系统自动挂载，可以在web界面设置挂载点，这样重启后仍然保留挂载
- 根据uuid选中你的u盘，作为外部overlay使用，然后点击保存&应用即可。
![](Pasted%20image%2020240302103042.png)


## ipv6中继
- 教程： https://www.right.com.cn/forum/thread-8309440-1-1.html
- 往期文章-> [index.zh-cn](../RAX3000M-openwrt使用ipv6中继/index.zh-cn.md)
## openclash
如果发现无法启动openclash，可能缺少内核clash
### 安装clash内核
- 方法1：覆写设置->修改github地址，然后点击启动openclash会自动安装
- 方法2：[手动下载](https://github.com/vernesong/OpenClash/releases/tag/Clash)并上传到/etc/openclash/core/clash，并给予执行权限。 

### 开启openclash无法登录游戏
- 参考： https://github.com/vernesong/OpenClash/issues/107
- 解决：运行模式使用TUN模式


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


### ntfs无法挂载

- 参考：
	- https://askubuntu.com/questions/500647/unable-to-mount-ntfs-external-hard-drive
使用 ntfs-3g 挂载报错
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

仍旧不行，则用电脑使用Diskgenius重新格式化成ntfs。（最好用ext4格式，稳定有一点）



