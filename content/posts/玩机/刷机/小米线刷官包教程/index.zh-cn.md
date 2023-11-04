---
title: 小米线刷官包教程
date: 2023-11-05T00:06:00.000+08:00
draft: "false"
tags:
  - 刷机
  - 小米
lastmod: 2023-11-05T03:22:00.000+08:00
categories: []
---



# 一、准备：1.线刷包 2. fastboot.exe

小米社区

[小米社区](https://web.vip.miui.com/page/info/mio/mio/detail?postId=37093637&app_version=dev.20051)

XDA

[MIFLASH[GUIDE]⚙ USE XIAOMI FLASH TOOL](https://forum.xda-developers.com/t/miflash-guide-use-xiaomi-flash-tool.4262425/)

[You searched for Max - Xiaomi Stock ROM](https://xiaomistockrom.com/?s=Max)

[Xiaomi Firmware Updater](https://xiaomifirmwareupdater.com/miui/hydrogen/stable/V10.2.2.0.NBCCNXM/)

小米刷机工具(亲测有bug)

[Download Xiaomi Flash Tool 20220507 - Official Tool](https://xiaomiflashtool.com/download/xiaomi-flash-tool-20220507)

# 二、刷机过程

## 1. 将fastboot.exe加入系统PATH环境变量

测试下fastboot命令是否生效

失败：

```c
E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot
'fastboot' is not recognized as an internal or external command,
operable program or batch file.
```

成功：

```c
E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot
fastboot: usage: no command
```

## 2. 手机进入fastboot模式

关机后，长按开机键+音量下，出现一个安卓机器人

## 2. 解压线刷包，进入firmware目录
![](attachments/Pasted%20image%2020231105022910.png)


打开终端，执行这个flash_all_expect_storage.bat脚本（不清理用户数据）

![](attachments/Pasted%20image%2020231105032144.png)
成功完整日志

```powershell
E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>flash_all_except_storage.bat

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  getvar product   2>&1  | findstr /r /c:"^product: *MSM8952$"   || echo Missmatching image and device
product: MSM8952

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  getvar product   2>&1  | findstr /r /c:"^product: *MSM8952$"   || exit /B 1
product: MSM8952

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  getvar soc_id   2>&1  | findstr /r /c:"^soc_id: *278"   && echo Missmatching image and device

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  getvar soc_id   2>&1  | findstr /r /c:"^soc_id: *278"   && exit /B 1

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash sbl1 E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\sbl1.mbn
Sending 'sbl1' (359 KB)                            OKAY [  0.014s]
Writing 'sbl1'                                     OKAY [  0.008s]
Finished. Total time: 0.029s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash tz E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\tz.mbn
Sending 'tz' (1331 KB)                             OKAY [  0.044s]
Writing 'tz'                                       OKAY [  0.032s]
Finished. Total time: 0.085s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash tzbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\tz.mbn
Sending 'tzbak' (1331 KB)                          OKAY [  0.043s]
Writing 'tzbak'                                    OKAY [  0.019s]
Finished. Total time: 0.071s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash rpm E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\rpm.mbn
Sending 'rpm' (162 KB)                             OKAY [  0.007s]
Writing 'rpm'                                      OKAY [  0.005s]
Finished. Total time: 0.022s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash rpmbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\rpm.mbn
Sending 'rpmbak' (162 KB)                          OKAY [  0.008s]
Writing 'rpmbak'                                   OKAY [  0.005s]
Finished. Total time: 0.020s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash aboot E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\emmc_appsboot.mbn
Sending 'aboot' (560 KB)                           OKAY [  0.020s]
Writing 'aboot'                                    OKAY [  0.008s]
Finished. Total time: 0.037s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash abootbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\emmc_appsboot.mbn
Sending 'abootbak' (560 KB)                        OKAY [  0.021s]
Writing 'abootbak'                                 OKAY [  0.010s]
Finished. Total time: 0.037s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash devcfg E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\devcfg.mbn
Sending 'devcfg' (32 KB)                           OKAY [  0.003s]
Writing 'devcfg'                                   OKAY [  0.003s]
Finished. Total time: 0.016s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash devcfgbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\devcfg.mbn
Sending 'devcfgbak' (32 KB)                        OKAY [  0.004s]
Writing 'devcfgbak'                                OKAY [  0.002s]
Finished. Total time: 0.014s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cmnlib E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cmnlib.mbn
Sending 'cmnlib' (192 KB)                          OKAY [  0.009s]
Writing 'cmnlib'                                   OKAY [  0.004s]
Finished. Total time: 0.021s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cmnlibbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cmnlib.mbn
Sending 'cmnlibbak' (192 KB)                       OKAY [  0.009s]
Writing 'cmnlibbak'                                OKAY [  0.006s]
Finished. Total time: 0.023s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cmnlib64 E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cmnlib64.mbn
Sending 'cmnlib64' (241 KB)                        OKAY [  0.009s]
Writing 'cmnlib64'                                 OKAY [  0.005s]
Finished. Total time: 0.023s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cmnlib64bak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cmnlib64.mbn
Sending 'cmnlib64bak' (241 KB)                     OKAY [  0.009s]
Writing 'cmnlib64bak'                              OKAY [  0.006s]
Finished. Total time: 0.023s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash modem E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\NON-HLOS.bin
Sending 'modem' (106496 KB)                        OKAY [  3.346s]
Writing 'modem'                                    OKAY [  1.343s]
Finished. Total time: 4.697s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash dsp E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\adspso.bin
Sending 'dsp' (16384 KB)                           OKAY [  0.527s]
Writing 'dsp'                                      OKAY [  0.208s]
Finished. Total time: 0.744s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash mdtp E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\mdtp.img
Sending 'mdtp' (3686 KB)                           OKAY [  0.120s]
Writing 'mdtp'                                     OKAY [  0.048s]
Finished. Total time: 0.174s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash keymaster E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\keymaster.mbn
Sending 'keymaster' (220 KB)                       OKAY [  0.009s]
Writing 'keymaster'                                OKAY [  0.008s]
Finished. Total time: 0.024s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash keymasterbak E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\keymaster.mbn
Sending 'keymasterbak' (220 KB)                    OKAY [  0.008s]
Writing 'keymasterbak'                             OKAY [  0.004s]
Finished. Total time: 0.023s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  erase boot
Erasing 'boot'                                     OKAY [  0.022s]
Finished. Total time: 0.026s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  erase sec
Erasing 'sec'                                      OKAY [  0.003s]
Finished. Total time: 0.007s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash misc E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\misc.img
Sending 'misc' (8 KB)                              OKAY [  0.003s]
Writing 'misc'                                     OKAY [  0.001s]
Finished. Total time: 0.012s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash system E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\system.img
Invalid sparse file format at header magic
Sending sparse 'system' 1/4 (524222 KB)            OKAY [ 16.944s]
Writing 'system'                                   OKAY [ 11.429s]
Sending sparse 'system' 2/4 (520901 KB)            OKAY [ 16.902s]
Writing 'system'                                   OKAY [  8.887s]
Sending sparse 'system' 3/4 (524285 KB)            OKAY [ 16.987s]
Writing 'system'                                   OKAY [  8.089s]
Sending sparse 'system' 4/4 (29652 KB)             OKAY [  1.007s]
Writing 'system'                                   OKAY [  0.591s]
Finished. Total time: 84.350s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cache E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cache.img
Sending 'cache' (19004 KB)                         OKAY [  0.603s]
Writing 'cache'                                    OKAY [  0.241s]
Finished. Total time: 0.851s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash recovery E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\recovery.img
Sending 'recovery' (13216 KB)                      OKAY [  0.418s]
Writing 'recovery'                                 OKAY [  0.163s]
Finished. Total time: 0.588s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash logo E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\logo.img
Sending 'logo' (1504 KB)                           OKAY [  0.051s]
Writing 'logo'                                     OKAY [  0.020s]
Finished. Total time: 0.079s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash splash E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\splash.img
Sending 'splash' (151 KB)                          OKAY [  0.006s]
Writing 'splash'                                   OKAY [  0.004s]
Finished. Total time: 0.018s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash cust E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\cust.img
Sending 'cust' (221442 KB)                         OKAY [  6.963s]
Writing 'cust'                                     OKAY [  2.902s]
Finished. Total time: 9.976s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  flash boot E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware\\images\\boot.img
Sending 'boot' (65536 KB)                          OKAY [  2.083s]
Writing 'boot'                                     OKAY [  0.806s]
Finished. Total time: 2.897s

E:\\flash\\Xiaomi_Mi_Max_Hydrogen_V7.5.6.0_14072016_XFT\\Firmware>fastboot  reboot
Rebooting                                          OKAY [  0.001s]
```