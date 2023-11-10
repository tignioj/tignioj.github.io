---
date: 2023-11-09T23:33:58.181Z
lastmod: 2023-11-10T06:58:19.679Z
categories:
  - 软件折腾
  - Obsidian
title: obsidian从零开始搭建hugo博客（一）环境安装
draft: "false"
tags:
  - hugo
  - obsidian
series:
  - 利用obsidian从零开始搭建hugo博客
---
# 安装hugo
https://github.com/gohugoio/hugo/releases/tag/v0.120.4
## 配置hugo环境变量

为什么要配置环境变量？配置的原因是使得这个二进制文件可以在终端任意地方执行，如果你不配置环境变量，那么终端只能在软件所在目录下执行该程序。

下载完成hugo之后，解压，找到`hugo.exe`目录所在的位置，复制上面的路径，例如我把它解压到了
`C:\Users\pcvmm\Desktop\software\mybin\hugo_extended_0.120.4_windows-amd64`

![](Pasted%20image%2020231110113241.png)

打开环境变量。此电脑右键->属性->高级系统设置->环境变量
![](Pasted%20image%2020231110112934.png)
双击Path，新建，然后粘贴
![](Pasted%20image%2020231110113453.png)
依次确定，环境变量窗口也点确定并关闭
![](Pasted%20image%2020231110113735.png)
## 验证hugo是否安装完成
打开终端（如果已经打开终端，需要重启终端）
输入`hugo version` ，显示版本号则成功配置。
```powershell
PS C:\Users\pcvmm> hugo version
hugo v0.120.4-f11bca5fec2ebb3a02727fb2a5cfb08da96fd9df+extended windows/amd64 BuildDate=2023-11-08T11:18:07Z VendorInfo=gohugoio
PS C:\Users\pcvmm>
```

# 安装git

https://git-scm.com/downloads

![](Pasted%20image%2020231110114437.png)
默认配置就行
![](Pasted%20image%2020231110114503.png)

![](Pasted%20image%2020231110114551.png)

![](Pasted%20image%2020231110114605.png)
选项虽然非常多，全部默认选项一直点Next就可以，其实不用搞这么复杂的。安装好后，你会发现git自动帮我们添加了git.exe的环境变量。也就是说即便你不用安装包的方式安装，而是下载的便携版的压缩包，解压之后仍然能够通过自己添加环境变量方式安装git
![](Pasted%20image%2020231110114850.png)

## 验证git是否安装完成
重启终端输入`git version` ,x显示版本号则表明安装成功
```powershell
PS C:\Users\pcvmm> git version
git version 2.42.0.windows.2
```

# 安装obsidian
https://obsidian.md/download

下载好后，直接打开即可
![](Pasted%20image%2020231110115654.png)


# 安装Vscode-用于修改配置
https://code.visualstudio.com/docs/?dv=win64user
