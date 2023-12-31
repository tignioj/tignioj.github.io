---
date: 2023-11-14T04:16:32.583Z
lastmod: 2023-12-31T20:40:17+08:00
categories:
  - 玩机
  - Linux
title: 终端添加代理命令
draft: "false"
tags:
  - 代理
  - 终端
  - 科学上网
series: 
---
对于Linux，编辑 `vim ~/.bashrc` (如果你是`zsh`则 `vim ~/.zshrc`)
添加以下代码，把HOST设置成你自己的代理服务器
```shell
PROXY_HOST=192.168.101.29:7890
alias proxy="
    export http_proxy=${PROXY_HOST};
    export https_proxy=${PROXY_HOST};
    export all_proxy=${PROXY_HOST};"
alias unproxy="
    unset http_proxy;
    unset https_proxy;
    unset all_proxy;"
```

然后载入配置 `source ~/.bashrc`，此时输入`proxy`，自动为当前脚本环境添加了代理。输入env查看
```bash
tignioj@localhost:~$ env
https_proxy=192.168.31.198:7890
http_proxy=192.168.31.198:7890
all_proxy=192.168.31.198:7890
```
如果要取消代理则输入`unproxy`

