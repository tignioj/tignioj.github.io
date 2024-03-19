---
date: 2024-03-20T00:02:59+08:00
lastmod: 2024-03-20T00:02:59+08:00
categories:
  - 玩机
  - QQBot
title: 如何在服务器部署TRSS-Yunzai
draft: "false"
tags:
  - TRSS
  - 机器人
series:
---

## 整体流程
安装trss->安装trss-yunzai->选择协议登录qq->安装常用插件 
- 参考官方教程： https://trss.me/Install/Docker.html
## 下载安装TRSS
root用户执行
```
bash <(curl -L gitee.com/TimeRainStarSky/TRSS_AllBot/raw/main/Install-Docker.sh)
```

## 安装TRSS-Yunzai插件
安装成功后，输入`tsab` 进入trss文字图形界面，键盘控制上下键移动到`TRSS-Yunzai`
![](Pasted%20image%2020240320000826.png)
确认下载
![](Pasted%20image%2020240320000902.png)

安装完成后，输入回车，又回到文字图形界面，点击`打开 TRSS-Yunzai` ，然后提示你窗口不存在，继续点击 `启动TRSS-Yunzai`
![](Pasted%20image%2020240320001156.png)

打开后，进入终端，你可以直接在终端输入指令进行一些操作。
- TRSS-Yunzai教程： https://github.com/TimeRainStarSky/Yunzai
```
[TRSSYz][00:12:51.593][INFO] [stdin] 发送文本：
欢迎使用【TRSS-Yunzai v3.1.3】
【#帮助】查看指令说明
【#状态】查看运行状态
【#日志】查看运行日志
【#重启】重新启动
【#更新】拉取 Git 更新
【#全部更新】更新全部插件
【#更新日志】查看更新日志
【#设置主人】设置主人账号
【#安装插件】查看可安装插件
```

假如输入错误，可以按下键盘快捷键`Ctrl + u`删除（退格键无法删除）
> 注意，这里输入的命令大多数是以图片方式返回，例如输入帮助，实际上是返回一张图片，终端无法查看，可以登录QQ或者其他社交平台后查看。

首次安装时，在终端上我们可以执行的操作是安装连接QQ的插件，当然，也支持其他社交平台，具体自己去挖掘。


## 绑定QQ

### 官方的QQ机器人
- https://github.com/TimeRainStarSky/Yunzai-QQBot-Plugin
- 个人账号仅支持QQ频道，企业账号才能在**群组中**使用官方的QQ机器人。官方的机器人好处就是不会掉线，缺点是没人用频道，企业账号也很难获得。


### 第三方机器人
- icqq本人测试是半个月封号一次，每次解封都要输入身份证并且进行人脸识别。
- lagrange才刚开始使用，具体能撑多久到时候再下结论。
- 这两种协议的共同特点都是需要签名服务器。icqq可以自己搭建本地签名服务器，但是lagrange目前不可以。
### icqq协议
##### 安装[icqq插件](https://github.com/TimeRainStarSky/Yunzai-ICQQ-Plugin)
直接在TRSS-Yunzai终端中输入以下指令就会自动安装插件
```
#安装ICQQ-Plugin
```


#### 搭建qq签名服务器
手动本地搭建签名服务器或者使用别人已有的服务器。本地搭建方法：[index.zh-cn](../TRSS部署QSign并使用/index.zh-cn.md)

#### 使icqq连接qq签名服务器
终端中输入指令`#QQ签名` + `签名服务器地址`
```
#QQ签名http://example.com
```

#### 连接账户密码
终端中输入指令
```
#QQ设置QQ号:密码:登录设备
```
例如下面命令表示登录qq号123，密码abc，设备为2
```
#QQ设置123:abc:2
```

设备代码为数字，不同的设备的消息限制不同，大多数人用的是2
- 安卓手机(1)
- 平板(2)
- 安卓手表(3)

### lagrange
遵循作者的约定，不到处乱传，自行研究 https://github.com/TimeRainStarSky/Yunzai-Lagrange-Plugin


## 安装常用插件
当你在TRSS-Yunzai终端的时候不要使用`Ctrl` + `c`，这样会退出终端。本质上trss的图形界面是tmux，你可以同时按下`Ctrl`+`b`后松开，接着按下`c`表示创建一个新的终端，在这里你可以继续输入tsab进入文字图形界面，继续选择`TRSS-Yunzai`，移动到`插件管理`->`Git插件管理`->`安装插件`
![](Pasted%20image%2020240320011223.png)

### 图鉴Atlas
例如#西风枪

### 抽卡插件flower-plugin
这个插件会覆盖trss-yunzai默认的抽卡插件，使用这个插件的原因是卡池更新比较同步
### 极限面板
梁氏插件

### 验证码GT-Mannual
这个需要手动安装 
https://gitee.com/haanxuan/GT-Manual


