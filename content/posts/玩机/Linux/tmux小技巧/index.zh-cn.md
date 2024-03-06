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
- 当前面板全屏 `Ctrl + B`, `Z`

### tmux滚动 `Ctrl + B`, `[`


## 配置文件
### tmux复制粘贴

如果要复制粘贴，则把要复制的那个窗口调整成全屏模式`Ctrl + B + Z` 然后复制，接着退出全屏模式即可。后面的可以不用看了，改配置是最麻烦且容易出错的。

--- 
tmux默认的复制粘贴有点反人类，用鼠标直接复制的格式是错误的。添加下面的配置到`~/.tmux.conf`开启vi复制模式。

https://unix.stackexchange.com/questions/318281/how-to-copy-and-paste-with-a-mouse-with-tmux

```
# Linux only
set -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
bind -n WheelDownPane select-pane -t= \; send-keys -M
bind -n C-WheelUpPane select-pane -t= \; copy-mode -e \; send-keys -M
bind -T copy-mode-vi    C-WheelUpPane   send-keys -X halfpage-up
bind -T copy-mode-vi    C-WheelDownPane send-keys -X halfpage-down
bind -T copy-mode-emacs C-WheelUpPane   send-keys -X halfpage-up
bind -T copy-mode-emacs C-WheelDownPane send-keys -X halfpage-down

# To copy, left click and drag to highlight text in yellow, 
# once you release left click yellow text will disappear and will automatically be available in clibboard
# # Use vim keybindings in copy mode
setw -g mode-keys vi
# Update default binding of `Enter` to also use copy-pipe
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection c"
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
```
使得配置生效
```
tmux source-file ~/.tmux.conf
```
然后回到session，按下`shift`，左键选择文本复制即可。

#### 方法二：复制插件[tmux-yank](https://github.com/tmux-plugins/tmux-yank)

首先安装插件管理[tpm](https://github.com/tmux-plugins/tpm)

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
使得插件管理生效，添加以下代码到~/.tmux.conf
```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Other examples:
# set -g @plugin 'github_username/plugin_name'
# set -g @plugin 'github_username/plugin_name#branch'
# set -g @plugin 'git@github.com:user/plugin'
# set -g @plugin 'git@bitbucket.com:user/plugin'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```
使得tpm生效
```
tmux source ~/.tmux.conf
```

接下来安装tmux-yank，网~/.tmux.conf中间添加
```
set -g @plugin 'tmux-plugins/tmux-yank'
```
打开tmux，输入`Ctrl + B` 然后按下`I`，开始安装插件。


#### 怎么复制？
添加两行
```
setw -g mode-keys vi
set -g mouse on
```
按下`Ctr + B` 再按下






### tmux 设置开启用鼠标设置窗口大小
```
set -g mouse on
```
