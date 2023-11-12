---
date: 2023-11-10T00:01:25.146Z
lastmod: 2023-11-12T09:15:47.570Z
categories:
  - 玩机
  - 虚拟机
title: Vmware17创建Windows11虚拟机
draft: "false"
tags:
  - 虚拟机
  - Windows11
  - Windows
  - Vmware
series: 
---
## 准备Windows11安装包和虚拟机安装包

进入官网界面，找到**下载 Windows 11 磁盘映像 (ISO)**，选择下载项为**Windows11(multi-edition ISO)**
[microsoft.com/zh-cn/software-download/windows11](https://www.microsoft.com/zh-cn/software-download/windows11)
![](Pasted%20image%2020231110080411.png)


官网下载Vmware
[下载 VMware Workstation Pro | CN](https://www.vmware.com/cn/products/workstation-pro/workstation-pro-evaluation.html)


## 初始化
打开虚拟机Vmware Workstation，依次点击文件->新建虚拟机，弹出新建虚拟机向导，选择典型安装，点击下一步
![](Pasted%20image%2020231110092554.png)

安装来源选择我们刚下载好的iso文件，继续点击下一步，会提示检测到Windows11，点击继续安装。
![](Pasted%20image%2020231110092631.png)


选择虚拟机映像存储位置，这里一定要选择固态硬盘的位置，因为机械硬盘启动系统很慢。最好不要选择你当前所在系统的同一个硬盘，否则启动起来也挺卡的，因为一个硬盘的IO是有限制的，启动虚拟机又占用了系统对磁盘的IO，当然如果你没有额外的固态硬盘，那还是比放在机械硬盘好。
![](Pasted%20image%2020231110081200.png)

加密信息页面，密码随便
![](Pasted%20image%2020231110092958.png)

磁盘大小意思一下，给个100G，然后选中**将虚拟机磁盘存储为单个文件**，继续点击下一步
![](Pasted%20image%2020231110093035.png)

点击下一步后，会给出默认的配置，我们可以点击**自定义硬件**，自己手动分配一下CPU和内存
![](Pasted%20image%2020231110093130.png)

根据自己的 硬件分配给虚拟机合适的资源。我电脑内存32G，给个8G没问题，建议最少给4G。处理器和核心数量至少2核心1线程。我选了2核心4线程。
![](Pasted%20image%2020231110081640.png)
选择完毕后点击关闭自定义硬件的窗口，然后点击完成
![](Pasted%20image%2020231110093223.png)
## 进入安装

上面的步骤完成后，点击开启此虚拟机就会进入自动安装。然后会弹出Press any Key Boot from CD，在这个界面我们快速按下键盘任意按键即可，否则会进入黑屏显示"Time out", 不用担心，再等一会就会出现微软的Logo

![](Pasted%20image%2020231110082041.png)

直接点击**下一页** -> **现在安装**
![](Pasted%20image%2020231110082202.png)
忽略密钥直接安装，点击**我没有产品密钥**
![](Pasted%20image%2020231110082303.png)

选择**Windows11 专业版**
![](Pasted%20image%2020231110082340.png)

选择**自定义安装：仅安装Windows系统（高级）**
![](Pasted%20image%2020231110093517.png)


直接点击下一页
![](Pasted%20image%2020231110093615.png)

慢慢等待安装
![](Pasted%20image%2020231110093652.png)
之后什么也不用做，等几分钟左右就会自动进入系统了
选择国家地区，后面根据自己的需要设定就好了
![](Pasted%20image%2020231110094629.png)
## 安装虚拟机工具
这时候刚装好的虚拟机是很卡的，并且拖拽虚拟机窗口时，Win11显示大小不会跟着变化，而是留下黑边，这是还没安装虚拟机工具Vmware Tools导致的。
我们找到虚拟机下面弹出的提示，点击**我已完成安装**后，会自动往系统插入一张虚拟光盘。
![](Pasted%20image%2020231110105008.png)

如果没有发现Vmware光盘，则点击**虚拟机**->**安装 Vmware Tools**
![](Pasted%20image%2020231110105246.png)


然后打开光盘，点击setup64，弹窗赋予管理员权限，选择典型安装，一路下一步即可
![](Pasted%20image%2020231110105336.png)
![](Pasted%20image%2020231110105640.png)
安装完成后，虚拟机win11会要求重启一次，重启即可（不是重启外部的系统，而是重启你刚装好的虚拟机）。