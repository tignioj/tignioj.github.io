---
title: obsidian插件开发（一）入门
date: 2023-11-05T17:51:00.000+08:00
draft: "false"
tags:
  - obsidian
  - obsidian插件
lastmod: 2023-11-05T16:55:58.050Z
categories:
  - 软件折腾
  - Obsidian
  - obsidian插件开发
series:
  - obsidian插件开发基础
---
# Obsidian介绍
obsidian是一款支持本地存储以及多种方式云端同步的笔记软件，界面很简洁，本质上开箱即用。但是如果你想要实现更多功能，要么去插件市场找，如果没有找到合适的，那就一起来动手自己做一个插件吧！

# 克隆插件样本到本地

打开官网 https://github.com/obsidianmd/obsidian-sample-plugin
 选择Create a new repository，这样你就会获得一份克隆
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105175821.png)

随便起一个名字
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105175947.png)

接着下载到本地
```
https://github.com/tignioj/myobsplugins.git
```

把他放到obsidian插件目录中
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105180129.png)

# 安装环境
进入我们刚下载好的插件目录
```
cd myobsplugins
```

安装依赖库
```
npm i
```

运行
```
npm run dev
```

此时打开obsidian我们就能看到插件了！
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105180607.png)


# 热加载Hot-reload
为了避免频繁开关插件，官方推荐热加载的方式来开发我们的插件，此时我们要额外下载一个插件。
https://github.com/pjeby/hot-reload

安装方式同理，把他下载到插件目录，然后重启obsidian就能手动启用了
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105180955.png)

# 编写代码

用vscode打开插件目录，编辑插件根目录下的main.ts

导入组件
```js
import { Notice, Plugin } from "obsidian";
```

找到  `async onload()`  方法，添加以下代码
```js
await this.loadSettings();
this.addRibbonIcon('dice', 'Greet',
() => { new Notice('Hello, world!'); });
```

这时候会看到编辑器左边多了一个小按钮，点击按钮就会弹出Hello world.
![](content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/Pasted%20image%2020231105181814.png)
恭喜你成功入门。

# 参考官网
https://docs.obsidian.md/Home



