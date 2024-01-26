---
date: 2024-01-25T20:33:52+08:00
lastmod: 2024-01-25T20:33:52+08:00
categories:
  - 玩机
  - docker
title: docker编译openwrt
draft: "false"
tags: 
series:
---
## docker编译官方openwrt
- docker提供环境： https://github.com/mwarning/docker-openwrt-build-env
- 官方编译步骤：  https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem


## docker编译lede
其实就是仿造 https://github.com/mwarning/docker-openwrt-build-env 这个编写了一个linux环境，然后在这个环境里面执行编译
### 系统准备
编写一个Dockerfile文件
```dockerfile
FROM debian:buster
# 使用国内镜像
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update &&\
    apt-get install -y \
        sudo time git-core subversion build-essential g++ bash make \
        libssl-dev patch libncurses5 libncurses5-dev zlib1g-dev gawk \
        flex gettext wget unzip xz-utils python python-distutils-extra \
        python3 python3-distutils-extra rsync curl libsnmp-dev liblzma-dev \
        libpam0g-dev cpio rsync gcc-multilib && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# set system wide dummy git config
RUN git config --system user.name "user" && git config --system user.email "user@example.com"

USER user
WORKDIR /home/user           
```

构建镜像
```shell
docker build -t openwrt_builder .
```

运行镜像
```shell
docker run  -v ./mybild:home/user openwrt_builder /bin/bash
```
### 编译前准备

```shell
git clone https://github.com/coolsnowwolf/lede
cd lede
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

Target-System选择x86后保存，接着下载 dl 库，编译固件 （-j 后面是线程数，第一次编译推荐用单线程）
```shell
make download -j8
make V=s -j$(nproc)
```

如果需要重新配置：

```shell
rm -rf .config
make menuconfig
make V=s -j$(nproc)
```



- 参考： https://github.com/coolsnowwolf/lede

## 编译openwrt


openwrt编译默认不带luci的web界面，你需要手动勾选安装，其余步骤完全相同
![](Pasted%20image%2020240126162948.png)

最好使用稳定版 `git checkout 指定版本`，而不是默认使用`HEAD`分支，如果你不使用稳定版，会带来两个问题
- 不包含web界面
- opkg安装程序会报错内核版本不匹配

```
# Download and update the sources
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git pull
 
# Select a specific code revision
git branch -a
git tag
git checkout v23.05.2 # 指定稳定版
 
# Update the feeds
./scripts/feeds update -a
./scripts/feeds install -a
 
# Configure the firmware image
make menuconfig
 
# Optional: configure the kernel (usually not required)
# Don't, unless have a strong reason to
make -j$(nproc) kernel_menuconfig
 
# Build the firmware image
make -j$(nproc) defconfig download clean world
```


- 参考： https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem



## github action
https://github.com/tignioj/Actions-OpenWrt/tree/main