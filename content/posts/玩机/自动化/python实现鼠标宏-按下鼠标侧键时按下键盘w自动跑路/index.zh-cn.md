---
date: 2024-01-13T20:12:08+08:00
lastmod: 2024-01-13T20:17:47+08:00
categories:
  - 玩机
  - 自动化
title: python实现鼠标宏-按下鼠标侧键时按下键盘w自动跑路
draft: "false"
tags:
  - 鼠标宏
  - python
  - 自动化
series:
---
## 需求
一直按着`w`按键跑路很累，希望鼠标前进键按下时，帮我们一直按着`w`，鼠标后退键按下时，停止长按。使用[pynput库](https://github.com/moses-palmer/pynput)可以帮我们解决这个问题。

## 使用conda创建python环境
```
conda create -n KeyBoardSimulate python==3.9
```
切换到刚安装的环境
```
conda activate KeyBoardSimulate
```
安装依赖库: `pynput`
```
pip install pynput
```

## 编写脚本
打开PyCharm，新建项目，选择conda创建好的环境
![](Pasted%20image%2020240113201643.png)
编写代码 `main.py`
```
from pynput import mouse  
from pynput.keyboard import Key, Controller  
  
"""  
PyCharm需要用管理员方式启动，否则游戏内输入无效！  
"""  
keyboard = Controller()  
  
def on_click(x, y, button, pressed):  
    if button == mouse.Button.x2:  # 当鼠标前进键按下时，按下w
        keyboard.press('w')  
  
    if button == mouse.Button.x1:  # 当鼠标后退键按下时, 释放w
        keyboard.release('w')  
  
# Collect events until released  
with mouse.Listener(on_click=on_click) as listener:  
    listener.join()
```
其中`Button.x2`对应鼠标侧键前进，`Button.x1`对应鼠标侧键后退，不同鼠标可能不一样。

## 游戏中运行
脚本启动后你会发现：在游戏外面能正常监听鼠标以及模拟键盘，但是打开游戏后监听失效。解决办法是PyCharm以管理员身份运行后再运行脚本。

## 参考
官方文档： https://pynput.readthedocs.io/en/latest/keyboard.html
