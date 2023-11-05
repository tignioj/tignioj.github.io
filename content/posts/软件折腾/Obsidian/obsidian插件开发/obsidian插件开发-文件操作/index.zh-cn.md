---
title: obsidian插件开发-文件操作
date: 2023-11-06T00:55:00.000+08:00
draft: "false"
tags:
  - obsidian
  - obsidian插件
  - api
lastmod: 2023-11-05T16:55:25.902Z
categories:
  - 软件折腾
  - Obsidian
  - obsidian插件开发
---

目录结构如图所示
![](Pasted%20image%2020231106010926.png)
## 获取当前仓库系统目录
```js
this.app.vault.adapter.basePath
```
![](Pasted%20image%2020231106011106.png)

## 获取所有文件
```js
this.app.vault.getFiles()
```

![](Pasted%20image%2020231106011657.png)

## 获取指定目录的文件列表
```js
this.app.vault.getAbstractFileByPath("content/posts").children
```

![](Pasted%20image%2020231106011354.png)


参考：
[Vault - Developer Documentation (obsidian.md)](https://docs.obsidian.md/Plugins/Vault)
