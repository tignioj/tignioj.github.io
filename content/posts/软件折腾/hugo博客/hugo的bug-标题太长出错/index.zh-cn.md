---
date: 2023-11-10T06:49:24.619Z
lastmod: 2023-11-10T06:49:24.619Z
categories:
  - 软件折腾
  - hugo博客
title: hugo的bug-标题太长出错
draft: "false"
tags: 
series:
---
## 错误描述
原本我在系列`利用obsidian从零开始搭建hugo博客` 的第一篇文章标题是`obsidian从零开始搭建hugo博客（一）安装git和hugo以及obsidian` 但是在服务器上总是不显示，发布到github上也是不显示这篇文章
## 排除错误
- 确认draft是false，所以不是这个原因
- 文档是`index.zh-cn.md`，属性title和目录名称一致，没问题。
- 中文符号`（）`改成英文符号`()`，仍旧不行
- 标题删减长度，例如结尾的obsidian改成obsidia就可以了，再加上n又不行了

## 得出结论
结论是标题长度太长！


## 蹊跷之处
然而我在虚拟机中新建立一个环境，同样的目录结构和标题，却能够正常显示，目前尚未搞清楚什么原因，暂时妥协用短一点的标题。