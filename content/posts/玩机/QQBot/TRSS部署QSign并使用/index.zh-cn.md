---
date: 2023-12-27T21:05:14.761Z
lastmod: 2023-12-27T21:05:14.761Z
categories:
  - 玩机
  - QQBot
title: TRSS部署QSign并使用
draft: "false"
tags:
  - QSign
  - TRSS
series:
---
# TRSS部署本地QSign并使用

# 一、安装QSign插件并启动

打开TRSS-Yunzai，进入插件管理
 ![](Pasted%20image%2020231228051057.png)
## 安装QSignServer
![](Pasted%20image%2020231228051111.png)
选择8978版本（这个版本稳定），78以上的版本容易报api异常错误，88版本可能会出现无法识别到版本号的问题。
 ![](Pasted%20image%2020231228051123.png)
然后启动就行。
 ![](Pasted%20image%2020231228051136.png)
## 验证是否开启成功

启动后，按下同时按下Ctrl+B，再按下C按键创建一个新的tmux窗口，输入

curl [http://localhost:2535](http://localhost:2535)
 
出现这一串json数据这个表明你已经成功开启QSign服务器
![](Pasted%20image%2020231228051152.png)
# 二、  TRSS-Yunzai配置QSign

输入tsab进入UI界面，进入TRSS-Yunzai，找到“修改配置文件"
![](Pasted%20image%2020231228051204.png)
找到ICQQ.yaml，按下回车进入编辑状态
![](Pasted%20image%2020231228051216.png)

编辑 sign_api_addr: 为 [http://localhost:2535/sign?key=TimeRainStarSky,](http://localhost:2535/sign?key=TimeRainStarSky,) 并按下Ctrl+S保存。按Ctrl+Q退出编辑。
![](Pasted%20image%2020231228051224.png)
重启TRSS-Yunzai即可。

