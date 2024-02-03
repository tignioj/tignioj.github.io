---
date: 2024-02-04T04:36:28+08:00
lastmod: 2024-02-04T04:36:28+08:00
categories:
  - 玩机
  - Linux
title: tmux小技巧
draft: "false"
tags:
  - tmux
series:
---
## 常用操作

### tmux会话操作
- 创建会话 `tmux new -t  <session_name>`
- 退出会话 `Ctrl + B`然后按下`D`
- 回到会话`tmux attach`

### tmux窗口操作
- 创建窗口 `Ctrl + B` 然后按下`C`
- 窗口列表 `Ctrl + B`, `W`
- 切换下一个窗口 `Ctrl + B`, 然后按下`N`
- 切换上一个窗口 `Ctrl + B`, 然后按下`P`

### tmux 面板操作
- 垂直分割 `Ctrl + B`, `%`
- 水平分割 `Ctrl + B`, `"`
- 切换布局 `Ctrl + B`, `<space>` 
- 调整窗口大小 `Ctrl + B` 按住不松手同时按下 `<上|下|左|右>`
- 关掉面板 `Ctrl + B`, `X`
- 

### tmux滚动 `Ctrl + B`, `[`



## 配置文件
### tmux复制粘贴
tmux默认的复制粘贴有点反人类，用鼠标直接复制的格式是错误的。添加下面的配置到`~/.tmux.conf`开启vi复制模式。

```
setw -g mode-keys vi
```
使得配置生效
```
tmux source-file ~/.tmux.conf
```
然后回到session，按下`shift`，左键选择文本复制即可。


### tmux 设置开启用鼠标设置窗口大小
```
set -g mouse on
```
