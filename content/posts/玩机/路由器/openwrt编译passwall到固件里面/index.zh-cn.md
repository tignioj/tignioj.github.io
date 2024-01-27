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


## 错误排查
### 依赖错误
通常报缺少依赖库的错误是你的软件源有问题，因为很难手动去一个个解决依赖。


### 内存不足
```
Creating filesystem with parameters:
    Size: 109051904
    Block size: 4096
    Blocks per group: 32768
    Inodes per group: 6656
    Inode size: 256
    Journal blocks: 0
    Label: rootfs
    Blocks: 26624
    Block groups: 1
    Reserved blocks: 0
    Reserved block group size: 7
error: ext4_allocate_best_fit_partial: failed to allocate 1541 blocks, out of space?
make[5]: *** [/home/user/openwrt/include/image.mk:348: /home/user/openwrt/build_dir/target-x86_64_musl/linux-x86_64/root.ext4] Error 1
make[5]: Leaving directory '/home/user/openwrt/target/linux/x86/image'
make[4]: *** [Makefile:24: install] Error 2
make[4]: Leaving directory '/home/user/openwrt/target/linux/x86'
make[3]: *** [Makefile:11: install] Error 2
make[3]: Leaving directory '/home/user/openwrt/target/linux'
time: target/linux/install#112.33#5.14#38.72
    ERROR: target/linux failed to build.
make[2]: *** [target/Makefile:30: target/linux/install] Error 1
make[2]: Leaving directory '/home/user/openwrt'
make[1]: *** [target/Makefile:24: /home/user/openwrt/staging_dir/target-x86_64_musl/stamp/.target_install] Error 2
make[1]: Leaving directory '/home/user/openwrt'
make: *** [/home/user/openwrt/include/toplevel.mk:232: world] Error 2
```

配置镜像参数
```
make menuconfig
```
Target Images -> Image Otions ，把Boot filesystem partition size和Keral partition size调大

![](Pasted%20image%2020240127153850.png)
