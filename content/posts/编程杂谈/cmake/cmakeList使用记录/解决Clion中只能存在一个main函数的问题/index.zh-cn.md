---
date: 2023-11-15T14:55:47.030Z
lastmod: 2023-11-17T15:40:27.202Z
categories:
  - 编程杂谈
  - cmake
  - cmakeList使用记录
title: 解决Clion中只能存在一个main函数的问题
draft: "false"
tags:
  - CLION
series: 
---
## 方法1:手动

在CMakeLists.txt中添加别名就可以

```cmake

add_executable(main1 main.cpp)
add_executable(main2 main2.cpp) // <--添加这个
```

来源：

[CLion工程中只能有一个main函数 &&怎么同时编写多个main函数的C文件_justinzwd的博客-CSDN博客_clion创建多个c项目](https://blog.csdn.net/justinzwd/article/details/85206640)

## 方法2:自动

```cmake

cmake_minimum_required(VERSION 3.26)
project(cmakeDemo1)

set(CMAKE_CXX_STANDARD 17)

file(GLOB files *.cpp) # 获取根目录的所有.cpp文件，保存到files变量中

foreach (file ${files}) # 遍历files变量
    message(${file}) # 此时会打印出绝对路径
    string(REGEX REPLACE ".+/(.+)\\.cpp" "\\1" exe ${file})
    message(${exe}) # 去掉路径和cpp后缀
    add_executable(${exe} ${file}) # 编译
endforeach ()
```

读取多级目录的cpp
```
# 同理，三层的话
file (GLOB files *.cpp */*.cpp */*/*.cpp)
```

来源 [如何在 clion 运行多个 main 函数 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/277990960)