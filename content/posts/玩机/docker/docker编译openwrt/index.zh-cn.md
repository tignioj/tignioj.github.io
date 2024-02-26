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
整体步骤
1. docker构建编译所需的系统镜像
2. 下载源代码
3. 首次编译
4. 选择自己需要的软件再次编译
5. 集成第三方软件包编译/编译单独ipk
官网教程： https://openwrt.org/docs/guide-developer/toolchain/start
## 准备编译环境

### 为什么要使用Docker编译？
- 因为容器可以随时创建、删除，但是如果你直接在系统上构建，系统被破坏了就不好恢复了！因此推荐使用Docker
- 如果你对Docker一无所知，可以看看入门教程，推荐这个 【【编程不良人】Docker&Docker-Compose 实战!】 https://www.bilibili.com/video/BV1wQ4y1Y7SE/?p=3&share_source=copy_web&vd_source=801146758c4483987cb1bd1d6f31883a

### 构建编译所需的系统镜像
为了不让编译环境污染宿主机，采用docker的方式编译，由docker为我们创建一个专门用于编译openwrt的系统，执行docker build的时候会自动下载编译工具所需要的依赖。你可以使用别人写好的Dockerfile文件： https://github.com/mwarning/docker-openwrt-build-env

```
git clone https://github.com/mwarning/docker-openwrt-builder.git
cd docker-openwrt-builder
```

查看Dockerfile，可以看到是基于debian的系统，安装了一些依赖，并创建了一个user用户（原因是不能使用root用户编译，也不能使用sudo执行编译）
- 不同系统所需依赖： https://openwrt.org/docs/guide-developer/toolchain/install-buildsystem

```
FROM debian:buster

RUN apt-get update &&\
    apt-get install -y \
        sudo time git-core subversion build-essential g++ bash make \
        libssl-dev patch libncurses5 libncurses5-dev zlib1g-dev gawk \
        flex gettext wget unzip xz-utils python python-distutils-extra \
        python3 python3-distutils-extra python3-setuptools swig rsync curl \
        libsnmp-dev liblzma-dev libpam0g-dev cpio rsync gcc-multilib && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# set system wide dummy git config
RUN git config --system user.name "user" && git config --system user.email "user@example.com"

USER user
WORKDIR /home/user
```

为了加快构建速度，使用国内的源，在`FROM debian:buster`后面添加一行
```
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
```

此时Dockerfile如下
```
FROM debian:buster
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update &&\
    apt-get install -y \
        sudo time git-core subversion build-essential g++ bash make \
        libssl-dev patch libncurses5 libncurses5-dev zlib1g-dev gawk \
        flex gettext wget unzip xz-utils python python-distutils-extra \
        python3 python3-distutils-extra python3-setuptools swig rsync curl \
        libsnmp-dev liblzma-dev libpam0g-dev cpio rsync gcc-multilib && \
    apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# set system wide dummy git config
RUN git config --system user.name "user" && git config --system user.email "user@example.com"

USER user
WORKDIR /home/user
```


构建镜像
```
docker build -t openwrt_builder .
```

![](Pasted%20image%2020240226093400.png)

执行此命令后，我们本地就多出了一个安装好编译依赖的debian镜像
```
root@tignioj:~/docker-openwrt-builder# docker images | grep openwrt
openwrt_builder            latest     0175798f5da9   4 weeks ago     716MB
```

创建编译系统的容器（镜像类似于系统的安装光盘，是固定的，容器类似于安装后的系统，可以开机关机、安装软件）
```
mkdir ~/mybuild
docker run -v ~/mybuild:/home/user --name openwrt_builder -itd openwrt_builder
```


进入容器
```
docker exec -it openwrt_builder /bin/bash
```

修改当前目录所属用户给user
```
sudo chown -R user:user .
```

## 首次编译

经过上面的步骤，我们进入了一个已经准备好编译环境的系统，此时可以开始跟着官方的步骤开始编译了
- 官方编译步骤：  https://openwrt.org/docs/guide-developer/toolchain/use-buildsystem

下载openwrt源代码：

```
git clone https://git.openwrt.org/openwrt/openwrt.git
```
进入代码目录
```
cd openwrt
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

### 配置选项
```
# Configure the firmware image
make menuconfig
```
先认识一下界面
![](Pasted%20image%2020240226085544.png)

在这个例子里面，我们暂时使用x86平台，到后面我们再使用指定的路由器平台，所以这些默认不动即可！
![](Pasted%20image%2020240226083923.png)


openwrt编译默认不带luci的web界面，你需要手动勾选安装，找到，
LuCI-> Collections-> luci，双击使得前面的变成`*`符号
![](Pasted%20image%2020240226085646.png)

设置web界面为中文， 双击使得前面的变成`*`符号
```
LuCI->Modules->Translations -> <*> Chinese Simplified (zh_Hans)
```


我们选择x86平台就是为了能在宿主机上运行，为了能docker中运行openwrt，找到target image勾选`tar.gz` (默认是勾选上的，没有自己勾上)
![](Pasted%20image%2020240127153010.png)

接着保存配置菜单，移动到Save，回车
![](Pasted%20image%2020240226085951.png)
选择OK
![](Pasted%20image%2020240226085958.png)
然后光标移动到EXIT退出菜单。

### 下载编译所需的库
```
# Build the firmware image
make download -j$(nproc)
```
- `-j$(nproc)`, 其中`nproc`会返回你系统的最大核心数量，例如-j8表示8线程编译
- `V=s`: 打印详细信息
### 开始编译
```
make -j$(nproc)
```
如果编译出错了，那么就单线程编译一遍
```
make -j1 V=s
```

到这里你可以看到在`bin/target/x86/64`目录下看到编译的固件

![](Pasted%20image%2020240226104638.png)

怎么在docker运行我们编译好的固件？请查看-> [index.zh-cn](../docker中运行自己编译的openwrt镜像/index.zh-cn.md)
## 选择插件编译进固件

经过第一次编译后，后面再次编译速度就会快很多，这时候我们就可以选择自己需要的插件编译进固件里面，例如 samba4

```
make menuconfig
```
找到LuCI->Applications->luci-app-samba4, 双击空格使得前面的`<>`变成`<*>`，其中`*`表示集成进固件里面, `M`表示作为ipk包。
![](Pasted%20image%2020240226105556.png)
光标移动到save，保存.config，然后再次编译，发现速度会快很多。

### 编译
```
make -j$(nproc) download
make -j$(nproc)
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

然后编译出来的固件，就会使用你的自定义配置
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
默认情况下，openwrt和lede后台地址都是192.168.1.1，有没有办法在编译的时候自定义呢？当然可以，只需要在编译的根目录下创建文件夹files，然后往里面添加初始化脚本即可。files相当于路由器的根目录
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
 


开始编译固件 （-j 后面是线程数，第一次编译推荐用单线程）
```shell
make download -j8
make -j$(nproc)
```
如果发现编译出错，那么可以使用单线程编译，并输出详细信息。大部分情况下的首次编译出现错误都是网络问题。

```
make -j1 V=s
```

编译完成后，可以在bin/target/平台目录下看到自己编译后的包
![](Pasted%20image%2020240226064650.png)

### 集成插件编译
经过前面的首次编译后，一些基础的包都已经编译完成，再次编译时候会跳过他们。此时选择自己需要的插件编译速度，就取决于插件本身。
```
make menuconfig
```
选择自己的插件后
```
make download -j$(nproc)
make -j$(nproc)
```


如果需要重新配置：

```shell
rm -rf .config
make menuconfig
make V=s -j$(nproc)
```

- 参考： https://github.com/coolsnowwolf/lede

## 集成第三方插件
经过上面的的步骤，你已经学会了基本的编译，此时可以尝试添加第三方的软件包  https://github.com/kenzok8/openwrt-packages
### 添加软件源
执行
```
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
git pull
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```
找到LuCI->Applications，勾选需要的软件，依赖会自动勾选

### 插件集成到固件里面
按下空格选中`M`表示作为ipk包编译
```
<M> luci-app-alist............ LuCI support for alist 
```
再次按下空格，出现`*`表示集成到固件里面
```
<*> luci-app-alist............ LuCI support for alist 
```

然后开始编译
```
make -j$(nproc) download
make -j$(nproc)
```

### 插件不集成到固件里面，而是单独作为ipk包
参考：
- https://3mile.github.io/archives/2019/0813123100/
- 
按下空格选中`M`表示作为ipk包编译
```
<M> luci-app-alist............ LuCI support for alist 
```
开始编译
```
make package/luci-app-alist/compile V=s
```

ipk生成路径，可以使用find命令查找
```
user@c6ba0d0ab225:~/lede$ find bin/  -name "*alist*"                                                                                       
bin/packages/aarch64_cortex-a53/kenzo/luci-i18n-alist-zh-cn_1.0.11-1_all.ipk
bin/packages/aarch64_cortex-a53/kenzo/alist_3.30.0-2_aarch64_cortex-a53.ipk
bin/packages/aarch64_cortex-a53/kenzo/luci-app-alist_1.0.11-1_all.ipk
user@c6ba0d0ab225:~/lede$ 
```

然后把这些ipk上传到路由器上执行即可
```
opkg install luci-i18n-alist-zh-cn_1.0.11-1_all.ipk
opkg install alist_3.30.0-2_aarch64_cortex-a53.ipk
opkg install luci-app-alist_1.0.11-1_all.ipk
```

或者在web界面上传安装

## docker编译immortalwrt
- 地址： https://github.com/immortalwrt/immortalwrt
- 简介： immortalwrt甚至集成了很多第三方的软件包，无需额外添加软件源，感觉更方便，编译步骤和lede一样，过程不再赘述。

### 构建镜像
#### 准备Dockerfile文件
Dockerfile文件，根据官网描述，建议基于ubuntu20.04-LTS，那么第一行的FROM就要改了
```
FROM ubuntu:20.04
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive  apt install -y \
  sudo ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
  g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
  libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses5-dev libncursesw5 \
  libncursesw5-dev libpython3-dev libreadline-dev libssl-dev libtool lld llvm lrzsz mkisofs msmtp \
  nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pip python3-ply \
  python3-docutils python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig \
  texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev 

RUN apt-get clean && \
    useradd -m user && \
    echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user

# set system wide dummy git config
RUN git config --system user.name "user" && git config --system user.email "user@example.com"

USER user
WORKDIR /home/user
```
注意到这里还加了一行 `DEBIAN_FRONTEND=noninteractive`，防止创建镜像的过程出现交互行为。



```
docker build -t immortalwrt_builder .
```
#### 创建容器
```
docker run -itd --name iwt_builder -v ~/iwt_builder:/home/user immortalwrt_builder 
```

#### 进入容器

```
docker exec -it iwt_builder bash
```

## 开始编译
注意，ubuntu系统需要修改用户目录权限给user才能下载源代码
```
sudo chown -R user:user .
```
下载源代码
```
git clone -b openwrt-23.05 --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt
cd immortalwrt
```

选择哪个分区可以在这里找 https://github.com/immortalwrt/immortalwrt/branches/active

安装
```
./scripts/feeds update -a
./scripts/feeds install -a
```

编译菜单，同样，先别选择插件，仅选择你的平台即可！
```
make menuconfig
```
首次编译
```
make -j $(nproc)
```
选择插件后再次编译
```
make menuconfig
make -j $(nproc)
```


## 编译的一些技巧
### tmux多窗口
tmux小技巧往期文章-> [index.zh-cn](../../Linux/tmux小技巧/index.zh-cn.md)
- 如果是远程ssh连接服务器编译，最好使用`tmux`，可以多窗口，且ssh断掉后进程不会中断，再次ssh进入服务器可以回到tmux会话。
创建一个名称为openwrt的session
```
tmux new -s openwrt
```
面板垂直分割，键盘按下快捷键
```
Ctrl + B + %
```
面板水平分割
```
Ctrl + B + "
```
退出tmux，但不退出tmux的进程
```
Ctrl + B + Q
```
回到tmux
```
tmux attach
```



## 云编译：github action
https://github.com/tignioj/Actions-OpenWrt/tree/main