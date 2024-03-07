---
date: 2024-03-04T10:23:58+08:00
lastmod: 2024-03-04T11:14:31+08:00
categories:
  - 玩机
  - 路由器
title: 在线选择自己的openwrt固件
draft: "false"
tags:
  - openwrt
  - immortalwrt
series:
---

## Immortalwrt
打开[固件选择器](https://firmware-selector.immortalwrt.org/)，左边选择你的机型，右边选择openwrt的版本，下方输入选择自己需要的软件
```
 lsblk fdisk parted cfdisk ntfs3-mount dmesg
 luci-app-openclash luci-app-dockerman luci-app-diskman luci-app-v2raya luci-app-samba4 luci-app-frpc luci-app-frps
 luci-app-ddns-go luci-app-fileassistant luci-app-wol luci-app-usb-printer luci-app-wifischedule luci-app-uugamebooster
 luci-app-alist luci-app-autoreboot luci-app-eqos luci-app-qos luci-app-qbittorrent luci-app-upnp luci-app-uhttpd
  luci-app-ttyd
```

第二个空白栏输入初始化命令，例如初始化路由器的LAN地址
```
uci set network.lan.ipaddr='192.168.30.1'
uci commit
```

提示：点击第二个输入框右下角的小齿轮会出现一些默认的初始化脚本插入到输入框。自己根据需要修改即可。
```
# Beware! This script will be in /rom/etc/uci-defaults/ as part of the image.
# Uncomment lines to apply:
#
# wlan_name="ImmortalWrt"
# wlan_password="12345678"
#
# root_password=""
# lan_ip_address="192.168.1.1"
#
# pppoe_username=""
# pppoe_password=""

# log potential errors
exec >/tmp/setup.log 2>&1

if [ -n "$root_password" ]; then
  (echo "$root_password"; sleep 1; echo "$root_password") | passwd > /dev/null
fi

# Configure LAN
# More options: https://openwrt.org/docs/guide-user/base-system/basic-networking
if [ -n "$lan_ip_address" ]; then
  uci set network.lan.ipaddr="$lan_ip_address"
  uci commit network
fi

# Configure WLAN
# More options: https://openwrt.org/docs/guide-user/network/wifi/basic#wi-fi_interfaces
if [ -n "$wlan_name" -a -n "$wlan_password" -a ${#wlan_password} -ge 8 ]; then
  uci set wireless.@wifi-device[0].disabled='0'
  uci set wireless.@wifi-iface[0].disabled='0'
  uci set wireless.@wifi-iface[0].encryption='psk2'
  uci set wireless.@wifi-iface[0].ssid="$wlan_name"
  uci set wireless.@wifi-iface[0].key="$wlan_password"
  uci commit wireless
fi

# Configure PPPoE
# More options: https://openwrt.org/docs/guide-user/network/wan/wan_interface_protocols#protocol_pppoe_ppp_over_ethernet
if [ -n "$pppoe_username" -a "$pppoe_password" ]; then
  uci set network.wan.proto=pppoe
  uci set network.wan.username="$pppoe_username"
  uci set network.wan.password="$pppoe_password"
  uci commit network
fi

echo "All done!"
```



![](Pasted%20image%2020240304102407.png)

### 区别uboot
- custom uboot：指的是第三方的uboot，比如[hanwckf的uboot](https://github.com/hanwckf/bl-mt798x/releases/tag/20240123)，大部分人用的都是第三方的uboot，此类uboot可以刷lede和immortalWRT的刷机包。

![](Pasted%20image%2020240306194327.png)

![](Pasted%20image%2020240306193706.png)

- openwrt uboot：官方的uboot，只能刷`itb`格式的uboot，和第三方不兼容，一般用tftpd方式刷入。
![](Pasted%20image%2020240306193724.png)


点击Request Build，就会开始构建，等待几分钟就会构建完成，下载即可。
![](Pasted%20image%2020240304103220.png)


刷机后发现很多插件都是英文版
![](Pasted%20image%2020240304111143.png)

这是因为没安装中文包，因此还需要安装语言包
- 系统的中文包是`luci-i18n-base-zh-cn`， 软件包管理器的中文包`luci-i18n-opkg-zh-cn`
- 插件对应中文则把`luci-app-xxxx`格式变成 `luci-i18n-xxxx-zh-cn`
- 例如终端插件`luci-app-ttyd`中文包是`luci-i18n-ttyd-zh-cn`

> 不是所有应用都有语言包，例如openclash和fileassistant就没有，你可以在这里查找插件对应的语言包名称 [Index of /releases/23.05.1/packages/x86_64/luci/ (immortalwrt.org)](https://downloads.immortalwrt.org/releases/23.05.1/packages/x86_64/luci/)

如果语言包报错了就删掉。

![](Pasted%20image%2020240305082501.png)

所以根据报错信息，删掉不存在的中文包即可。
```
luci-i18n-opkg-zh-cn luci-i18n-base-zh-cn 
luci-i18n-dockerman-zh-cn luci-i18n-diskman-zh-cn luci-i18n-v2raya-zh-cn luci-i18n-samba4-zh-cn luci-i18n-frpc-zh-cn luci-i18n-frps-zh-cn
luci-i18n-ddns-go-zh-cn luci-i18n-wol-zh-cn luci-i18n-usb-printer-zh-cn luci-i18n-wifischedule-zh-cn luci-i18n-uugamebooster-zh-cn
luci-i18n-alist-zh-cn luci-i18n-autoreboot-zh-cn luci-i18n-eqos-zh-cn luci-i18n-qos-zh-cn luci-i18n-qbittorrent-zh-cn luci-i18n-upnp-zh-cn luci-i18n-uhttpd-zh-cn  luci-i18n-ttyd-zh-cn
```

然后重新点击 Request Build即可
![](Pasted%20image%2020240305083925.png)


你也可以在刷好固件后再安装中文包，找到软件包，过滤插件名称，然后找到i18n那行，安装即可
![](Pasted%20image%2020240305090730.png)



##  查询插件信息
打开[插件地址](https://github.com/immortalwrt/luci/tree/master/applications)， 点开要了解的插件，找到po/zh_Hands，就可以看到插件说明
![](Pasted%20image%2020240307173245.png)



如果里面没有自己要的插件，可以尝试手动安装，插件地址集合： [kenzok8/openwrt-packages: openwrt常用软件包 (github.com)](https://github.com/kenzok8/openwrt-packages)