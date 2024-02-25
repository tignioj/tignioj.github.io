---
date: 2024-01-25T20:33:52+08:00
lastmod: 2024-02-26T06:22:46+08:00
categories:
  - 玩机
  - docker
title: docker编译openwrt
draft: "false"
tags:
  - openwrt
  - docker
series: 
---
## docker编译官方openwrt
总体步骤
1. 准备编译所需的系统镜像
2. 下载源代码
3. 首次编译
4. 选择自己需要的软件再次编译


## 准备编译环境
- docker提供环境： https://github.com/mwarning/docker-openwrt-build-env
### 构建编译所需的系统镜像
为了不让编译环境污染宿主机，采用docker的方式编译，由docker为我们创建一个专门用于编译openwrt的系统，执行docker build的时候会自动下载编译工具所需要的依赖。

```
git clone https://github.com/mwarning/docker-openwrt-builder.git
cd docker-openwrt-builder
```

查看Dockerfile，可以看到是基于debian的系统，并创建了一个user用户。
```
FROM debian:buster

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


构建镜像，执行此命令后，我们本地就多出了一个安装好编译依赖的debian镜像
```
docker build -t openwrt_builder .
```

- 不同系统所需依赖： https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem


创建编译系统的容器
```
mkdir ~/mybuild
docker run -v ~/mybuild:/home/user --name openwrt_builder -it openwrt_builder /bin/bash
```

### 编译准备
经过上面的步骤，我们进入了一个已经准备好编译环境的系统，此时可以开始跟着官方的步骤开始编译了。

首先进入容器
```
docker exec -it openwrt_builder /bin/bash
```

- 官方编译步骤：  https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem

```
# Download and update the sources
git clone https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
git pull
```

### 选择稳定版本分支
最好使用稳定版 `git checkout 指定版本`，而不是默认使用`HEAD`分支，如果你不使用稳定版，会带来两个问题
- 不包含web界面（当然，你可以手动在menuconfig中勾选）
- opkg安装程序会报错内核版本不匹配

```
# Select a specific code revision
git branch -a
git tag
git checkout v23.05.2 # 指定稳定版
```

### 更新feeds
```
# Update the feeds
./scripts/feeds update -a
./scripts/feeds install -a
```


## 配置选项
```
# Configure the firmware image
make menuconfig
```

openwrt编译默认不带luci的web界面，你需要手动勾选安装luci
![](Pasted%20image%2020240126162948.png)

如果想要在docker中运行openwrt，请勾选`tar.gz`
![](Pasted%20image%2020240127153010.png)


可选项
```
# Optional: configure the kernel (usually not required)
# Don't, unless have a strong reason to
make -j$(nproc) kernel_menuconfig
```


## 下载编译所需的库
```
# Build the firmware image
make download -j$(nproc)
```
- `-j$(nproc)`, 其中`nproc`会返回你系统的最大核心数量，例如-j8表示8线程编译
- `V=s`: 打印详细信息

## 开始编译
```
make -j$(nproc)
```
如果编译出错了，那么就单线程编译一遍
```
make -j1 V=s
```


## 自定义配置文件
例如，自定义ip地址，我们可以在编译根目录下创建files目录，相当于路由器的根目录。此时我们往files/etc/uci-defaults/添加脚本，等同于往路由器的/etc/uci-defaults/中添加脚本。
- 在uci/defaults/99-custom添加内容

```
uci -q batch << EOI
set network.lan.ipaddr='192.168.30.99'
set network.lan.dns='192.168.30.1'
set network.lan.gateway='192.168.30.1'
EOI
```


## 差异配置
暂时不清楚有什么优点
 
- 参考： https://openwrt.org/docs/guide-developer/uci-defaults
- uci命令： https://openwrt.org/docs/techref/uci


## docker编译lede
- 简介：lede是openwrt的一个分支，默认使用中文，集成了一些基本的插件。
- 编译：类似openwrt，其实就是仿造 https://github.com/mwarning/docker-openwrt-build-env 这个编写了一个linux环境，然后在这个环境里面执行编译
### 系统准备
这次我们不下载他们Dockerfile，而是自己仿造一个
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
docker build -t lede_builder .
```

运行镜像
```shell
docker run  -v ./mybild:home/user lede_builder /bin/bash
```
### 编译前准备

```shell
git clone https://github.com/coolsnowwolf/lede
cd lede
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

第一次编译建议不要勾选任何插件，因为第一次编译包含了很多基础包的编译，过程比较持久，如果加上了插件造成报错可能会感到困惑：到底是插件的问题，还是我系统没配置好？因此第一次仅仅勾选你的路由器平台即可。

### 自定义配置
默认情况况下，openwrt和lede默认后台地址都是192.168.1.1，有没有办法在编译的时候自定义呢？当然可以，只需要在编译的根目录下创建文件夹files，然后往里面添加初始化脚本即可。files相当于路由器的根目录
```
mkdir -p files/etc/uci-defautls
```

假设我们要自定义ip地址
```
vim files/uci-defaults/99-custom
```

往里面添加内容
```
uci -q batch << EOI
set network.lan.ipaddr='192.168.30.101'
set network.lan.dns='192.168.30.1'
set network.lan.gateway='192.168.30.1'
set network.lan.ipaddr='192.168.30.101'
delete uhttpd.main.listen_https
EOI
```

注意到我这里设置了uhttpd的https监听地址修改成了空字符串，原因是lede默认没有安装luci-app-openssl，如果不关闭https监听会无法启动web界面
 



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



## github action
https://github.com/tignioj/Actions-OpenWrt/tree/main