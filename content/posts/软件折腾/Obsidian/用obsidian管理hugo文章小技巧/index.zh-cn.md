---
title: 用obsidian管理hugo文章小技巧
date: 2023-11-05T23:31:00.000+08:00
draft: "false"
tags:
  - obsidian
  - shell-command
  - hugo
lastmod: 2023-11-12T16:01:44.682Z
categories:
  - 软件折腾
  - Obsidian
series: 
description: obsidian管理hugo文章的一些技巧
---

## 一、搜索技巧
![](Pasted%20image%2020231109053716.png)

举例：查找所有草稿，即查找所有markdown文件中，属性draft为true的帖子。obsidian提供了一个 `[propertiees: value]` 的方法，于是我们输入 `["draft": true]`，于是显示出结果如下
![](Pasted%20image%2020231109053543.png)

但是由于hugo的文章的文件名不作为标题，如何显示标题呢？只需要加上title就可以，例如。
非常好用的小技巧！
![](Pasted%20image%2020231109053435.png)


## 二、发布技巧

使用shell commands插件一键发布文档到github
例如我们原本需要手动输入命令提交
```shell
git add content/posts/xxxx.md
git commit -m "xxx"
git push origin main
```
我们可以把这些命令放进一个按钮里面，点击就可以立马提交。
```shell
git add {{folder_path:relative}}
git commit -m "{{folder_name}}"
git push origin main
```

设置如下。
![](Pasted%20image%2020231109072252.png)
点击小齿轮，在General那里设置Alias别名
![](Pasted%20image%2020231109074724.png)

为了明确我们当前提交的文档，最好来个确认框。

首先找到Preactions，新建一个Prompts提示框。打开`review shell command in prompt`,表示预览当前命令

![](Pasted%20image%2020231109072425.png)

接着让刚刚创建的命令关联这个prompt，找到命令，先点击小齿轮
![](Pasted%20image%2020231109074021.png)
找到Preactions，选中我们刚刚创建的promot
![](Pasted%20image%2020231109074121.png)


然后我们通过快捷命令就可以发布文章了。打开文档后，按下快捷键`Ctrl + p`，弹出输入框，输入`发布文档`，点击它，就会弹出确认框
![](Pasted%20image%2020231109074556.png)

![](Pasted%20image%2020231109074858.png)

但是此时会发现没有输出，这是因为默认情况下，正常执行不输出，为了能看到提交的情况，我们打开输出。

点击命令对应的小齿轮，找到Output，在Output channel for stdout中选择Notification ballon。也就是说标准输出都会弹出一个小气球显示结果信息
![](Pasted%20image%2020231109075055.png)

于是我们再次执行代码后，成功输出了信息。

![](Pasted%20image%2020231109075008.png)



