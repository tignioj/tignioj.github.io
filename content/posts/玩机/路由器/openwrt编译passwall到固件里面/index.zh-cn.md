---
date: 2024-01-27T15:18:39+08:00
lastmod: 2024-01-27T15:20:05+08:00
categories:
  - 玩机
  - 路由器
title: openwrt编译passwall到固件里面
draft: "false"
tags:
  - openwrt
  - passwall
  - 科学上网
series:
---

## 添加软件源
找到这个列表 https://github.com/kenzok8/openwrt-packages
执行
```
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```


## 配置菜单
选择`luci->application-> luci-app-passwall2`，配置全部默认。

**注意，请到Base System中查看是否同时勾选了dnsmasq和dnsmasq-full，如果是，请取消勾选dnsmasq，否则会冲突。**

![](Pasted%20image%2020240127152722.png)

## 编译
```
make download -j8
```

开始编译 
```
make -j$(nproc)
```

通常报缺少依赖库的错误是你的软件源有问题，因为很难手动去一个个解决依赖。

