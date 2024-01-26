---
date: 2024-01-26T18:09:06+08:00
lastmod: 2024-01-26T18:09:06+08:00
categories:
  - 玩机
  - 路由器
title: 编译openwrt单独的包
draft: "false"
tags:
  - openwrt
  - ailst
  - NAS
series:
---
## alist
https://github.com/sbwml/luci-app-alist

```
git clone https://github.com/sbwml/luci-app-alist package/alist
make menuconfig # choose LUCI -> Applications -> luci-app-alist
make package/alist/luci-app-alist/compile V=s # build luci-app-alist
```

编译完成后，bin/packages/x86_64/base中找到
```
root@tignioj:~/mybuild/openwrt/bin/packages/x86_64/base# ls  *alist*
alist_3.30.0-2_x86_64.ipk  luci-app-alist_1.0.11_all.ipk  luci-i18n-alist-zh-cn_git-23.223.34172-ff70952_all.ipk
```

复制到openwrt容器即可
```
cd ~/mybuild/openwrt/bin/packages/x86_64/base/
docker cp alist_3.30.0-2_x86_64.ipk  openwrt:/root
docker cp luci-app-alist_1.0.11_all.ipk  openwrt:/root
docker cp luci-i18n-alist-zh-cn_git-23.223.34172-ff70952_all.ipk  openwrt:/root
```

进入openwrt，安装这三个ipk
```
cd /root
opkg install alist_3.30.0-2_x86_64.ipk
opkg install luci-app-alist_1.0.11_all.ipk 
opkg luci-i18n-alist-zh-cn_git-23.223.34172-ff70952_all.ipk
```


教程： https://www.bilibili.com/video/BV1M441147jK/?spm_id_from=333.337.search-card.all.click&vd_source=cdd8cee3d9edbcdd99486a833d261c72