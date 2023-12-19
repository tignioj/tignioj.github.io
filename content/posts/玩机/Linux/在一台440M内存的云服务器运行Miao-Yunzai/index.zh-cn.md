---
date: 2023-12-17T20:54:41.229Z
lastmod: 2023-12-17T20:54:41.229Z
categories:
  - 玩机
  - Linux
title: 在一台440M内存的云服务器运行Miao-Yunzai
draft: "false"
tags:
  - 机器人
  - Miao-Yunzai
  - 虚拟内存
  - swap
  - chromium-headless
series:
---
## 运行方案分析
三个方案运行yunzai：
1. trss，卡死，放弃
2. miao-yunzai 自带的docker-compose.yml，容器构建速度太慢，放弃
3. 直接用npm安装nodejs运行，可行。

环境：CentOS7.9，下载[Miao-yunzai](https://github.com/yoimiya-kokomi/Miao-Yunzai)项目
```
# 使用Gitee
git clone --depth=1 https://gitee.com/yoimiya-kokomi/Miao-Yunzai.git
cd Miao-Yunzai 
git clone --depth=1 https://gitee.com/yoimiya-kokomi/miao-plugin.git ./plugins/miao-plugin/
```

# 安装nodejs
```
yum install nodejs
```

如果不行，则使用nvm安装nodejs https://linuxize.com/post/how-to-install-node-js-on-centos-7/
```
yum install nvm
nvm install 16.20
```
查看有哪些nodejs版本 `nvm list`
```
[root@localhost]# nvm list
default -> node (-> v21.4.0)
node -> stable (-> v21.4.0) (default)
stable -> 21.4 (-> v21.4.0) (default)
iojs -> N/A (default)
unstable -> N/A (default)
lts/* -> lts/iron (-> v20.10.0)
lts/argon -> v4.9.1 (-> N/A)
lts/boron -> v6.17.1 (-> N/A)
lts/carbon -> v8.17.0 (-> N/A)
lts/dubnium -> v10.24.1 (-> N/A)
lts/erbium -> v12.22.12 (-> N/A)
lts/fermium -> v14.21.3 (-> N/A)
lts/gallium -> v16.20.2
lts/hydrogen -> v18.19.0 (-> N/A)
lts/iron -> v20.10.0

```
注：报错则不要安装18以上版本的nodejs
```
node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
node: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by node)
node: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by node)
node: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by node)
node: /lib64/libc.so.6: version `GLIBC_2.27' not found (required by node)
node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
node: /lib64/libc.so.6: version `GLIBC_2.25' not found (required by node)
```

如果安装了多个版本的nodejs，指定版本可以使用nvm use
```
nv use 16.20
```


安装pnpm
```
# 使用npmjs.org安装
npm install pnpm -g

# 指定国内源npmmirror.com安装
npm --registry=https://registry.npmmirror.com install pnpm -g
```

注：如果没有npm则先安装npm
```
yum install npm
```


## 安装redis
```
yum install redis
```
启动redis
```
redis-server 
```

通过源码方式安装redis
https://redis.io/docs/install/install-redis/install-redis-from-source/

```
wget https://download.redis.io/redis-stable.tar.gz```bash
tar -xzvf redis-stable.tar.gz
cd redis-stable
make
```



## 运行node app，发现报错
```
node app
```

```
[MiaoYz][22:56:45.078][MARK] 监听事件错误：online.js
[MiaoYz][22:56:45.079][ERRO] Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.8' not found (required by /root/Miao-Yunzai/node_modules/.pnpm/sqlite3@5.1.6/node_modules/sqlite3/lib/binding/napi-v6-linux-glibc-x64/node_sqlite3.node)
    at Object.Module._extensions..node (node:internal/modules/cjs/loader:1282:18)
    at Module.load (node:internal/modules/cjs/loader:1076:32)
    at Function.Module._load (node:internal/modules/cjs/loader:911:12)
    at Module.require (node:internal/modules/cjs/loader:1100:19)
    at require (node:internal/modules/cjs/helpers:119:18)
    at Object.<anonymous> (/root/Miao-Yunzai/node_modules/.pnpm/sqlite3@5.1.6/node_modules/sqlite3/lib/sqlite3-binding.js:4:17)
    at Module._compile (node:internal/modules/cjs/loader:1198:14)
    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1252:10)
    at Module.load (node:internal/modules/cjs/loader:1076:32)
    at Function.Module._load (node:internal/modules/cjs/loader:911:12) {
  code: 'ERR_DLOPEN_FAILED'
}
[MiaoYz][22:56:45.121][MARK] 监听事件错误：request.js
[MiaoYz][22:56:45.121][ERRO] Error: /lib64/libstdc++.so.6: version `CXXABI_1.3.8' not found (required by /root/Miao-Yunzai/node_modules/.pnpm/sqlite3@5.1.6/node_modules/sqlite3/lib/binding/napi-v6-linux-glibc-x64/node_sqlite3.node)
    at Object.Module._extensions..node (node:internal/modules/cjs/loader:1282:18)
    at Module.load (node:internal/modules/cjs/loader:1076:32)
    at Function.Module._load (node:internal/modules/cjs/loader:911:12)
    at Module.require (node:internal/modules/cjs/loader:1100:19)
    at require (node:internal/modules/cjs/helpers:119:18)
    at Object.<anonymous> (/root/Miao-Yunzai/node_modules/.pnpm/sqlite3@5.1.6/node_modules/sqlite3/lib/sqlite3-binding.js:4:17)
    at Module._compile (node:internal/modules/cjs/loader:1198:14)
    at Object.Module._extensions..js (node:internal/modules/cjs/loader:1252:10)
    at Module.load (node:internal/modules/cjs/loader:1076:32)
    at Function.Module._load (node:internal/modules/cjs/loader:911:12) {
  code: 'ERR_DLOPEN_FAILED'
```

## 排错
- 参考： https://github.com/TryGhost/node-sqlite3/issues/1582#issuecomment-1198949710
解决：
1. 下载gcc10-libstdc++，来源：[https://mirror.ghettoforge.org/distributions/gf/el/7/gf/x86_64/](https://mirror.ghettoforge.org/distributions/gf/el/7/gf/x86_64/)
2. 安装 `rpm -i gcc10-libstdc++-10.2.1-7.gf.el7.x86_64.rpm`, 此时 /opt/会多出一个gcc10目录
3. 设置环境变量并运行miao-yunzai `LD_LIBRARY_PATH=$PATH:/opt/gcc-10.2.1/usr/lib64/ node app`


终于可以成功登录，再次运行：发现puppeteer响应速度超过40秒，以至于几乎无法使用。


## 优化1：给系统添加swap分区
参考： https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-centos-7

查看系统是否存在分区
```
free -m
```
显然没有
```
             total       used       free     shared    buffers     cached
Mem:          3953        315       3637          8         11        107
-/+ buffers/cache:        196       3756
Swap:            0          0       4095
```

### 创建swap分区
3G有多了
```
sudo dd if=/dev/zero of=/swapfile count=3072 bs=1MiB
```

### 启用swap
```
sudo chmod 600 /swapfile
```

```
sudo mkswap /swapfile
```

```
sudo swapon /swapfile
```

查看swap
```
swapon -s
```

```
[root@localhost ]# swapon -s
Filename				Type		Size	Used	Priority
/swapfile                              	file	3145724	40556	-2
```


```
[root@localhost ]# free -h
              total        used        free      shared  buff/cache   available
Mem:           447M         93M         50M         44K        303M        342M
Swap:          3.0G         0M        3.0G

```

### 持久化swap
```
vim /etc/fstab
```
添加以下内容到fstab底部
```
/swapfile   swap    swap    sw  0   0
```


### 调整swap调度策略
```
cat /proc/sys/vm/swappiness
0
```
调整为0以上，否则puppeteer可能不适用交换内存，我直接设置为100

```
sudo sysctl vm.swappiness=100
```
系统文件也改一下
```
vim /etc/sysctl.conf
```

```
vm.swappiness = 100
```


## 优化2：使用自定义chromium
### 安装chromium-headless
```
yum install chromium-headless
```

- 假如报错：No package chromium-headless available. Error: Nothing to do
- 解决： [yum安装出现No package ****** available-CSDN博客](https://blog.csdn.net/zhangxiaoyang0/article/details/109162240)
```
yum intsall epel-release
yum clean all
yum update
yum makecache
```



[查看chromium-headless安装位置](https://stackoverflow.com/questions/46357102/chromium-headless-installed-path-in-centos-7)
```
/usr/lib64/chromium-browser/headless_shell
```

### 安装puppeteer-core
由于不再使用puppeteer自带的chrome，我们把puppeteer库该为puppeteer-core
进入Miao-yunzai项目根目录，修改package.json
```
vim package.json
```

添加依赖
```
 "puppeteer-core": "^21.5.2",
```
安装依赖
```
pnpm install -P
```

修改渲染器代码
```
vim renderers/puppeteer/lib/puppeteer.js
```

修改导入的包
```
# import puppeteer from 'puppeteer'
import puppeteer from 'puppeteer-core'
```

### 修改启动参数，指定chromium的位置
```
    this.config = {
      headless: 'new', //Data.def(config.headless, true),
      executablePath: '/usr/lib64/chromium-browser/headless_shell',
      args: Data.def(config.args, [
        '--disable-gpu',
        '--disable-setuid-sandbox',
        '--no-sandbox',
        '--no-zygote'
      ])

```

### 乱码解决
```
yum groupinstall fonts -y
```
### 重启启动miao-yunzai
```
LD_LIBRARY_PATH=$PATH:/opt/gcc-10.2.1/usr/lib64/ node app
```


