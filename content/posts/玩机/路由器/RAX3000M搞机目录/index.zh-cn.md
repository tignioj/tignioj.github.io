---
date: 2024-02-21T00:10:40+08:00
lastmod: 2024-02-21T00:10:58+08:00
categories:
  - 玩机
  - 路由器
title: RAX3000M搞机目录
draft: "false"
tags:
  - RAX3000M
  - openwrt
  - immortalwrt
series:
---

### 备份
参考： https://www.right.com.cn/forum/thread-8306986-1-1.html

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


## 开启SSH
- 参考1： https://blog.csdn.net/weixin_45357522/article/details/135342315
- 参考2： https://blog.iplayloli.com/rax3000m-router-flashing-explanation-nanny-tutorial-easy-to-get-started.html


### 导出配置
配置管理->导出配置文件
### 解密
解密后你会获得一个etc目录，里面有配置文件
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



## 刷入uboot

### 方法1：h大的uboot

- 下载链接： https://github.com/hanwckf/bl-mt798x/releases/tag/20240123
- 检查md5
```
root@RAX3000M:/tmp# md5sum mt7981_cmcc_rax3000m-emmc-fip.bin 
2deacf30fe9cb6ef8a0ce646f507bfb4  mt7981_cmcc_rax3000m-emmc-fip.bin
```

- 刷入uboot命令
```
root@RAX3000M:/tmp# dd if=/tmp/mt7981_cmcc_rax3000m-emmc-fip.bin of=/dev/mmcblk0p3
1148+1 records in
1148+1 records out
root@RAX3000M:/tmp# sync
```

- 进入uboot
	- 断开电源，按住reset，插上电源，等待红灯亮起。
	- LAN连接电脑
	- 电脑修改IP地址为192.168.1.2， 默认网关192.168.1.1
	- 浏览器打开192.168.1.1


### 方法2：immortalwrt的uboot
参考： immortalwrt刷入教程
- https://github.com/AngelaCooljx/Actions-rax3000m-emmc
- https://www.right.com.cn/forum/thread-8306986-1-1.html

![](Pasted%20image%2020240224012602.png)


## 刷入openwrt
- 教程： https://www.1234f.com/sj/technique/xxzl/20231108/560.html
- 视频教程： https://www.bilibili.com/video/BV1dj411b7yW/?spm_id_from=333.337.search-card.all.click&vd_source=cdd8cee3d9edbcdd99486a833d261c72


- itb 格式怎么刷？ https://www.right.com.cn/forum/thread-8316238-1-1.html


## ipv6中继
教程： https://www.right.com.cn/forum/thread-8309440-1-1.html



## openclash
如果发现无法启动openclash，可能缺少内核clash
### 安装clash内核
- 方法1：修改github地址
- 方法2：手动下载并上传到/etc/openclash/core/clash，并给予执行权限。

