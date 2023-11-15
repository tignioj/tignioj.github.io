---
date: 2023-11-15T09:25:50.765Z
lastmod: 2023-11-15T12:00:12.545Z
categories:
  - 编程杂谈
  - cmake
  - cmakeList使用记录
title: CMakeLists制作静态库与动态库并被使用
draft: "false"
tags:
  - cmake
series:
---


目录结构如下
![](Pasted%20image%2020231115191853.png)

### 子目录：静态库写法(会把依赖库编译进可执行文件中)
`myutil/CMakeLists.txt`
```cmake
set(CMAKE_CXX_STANDARD 20) 
# 当前目录下所有.c文件保存到srcs变量里面去
file(GLOB srcs CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
        )

message(${srcs})

# 暴露自己：我是一个依赖库（STATIC：静态库，生成libmyutil.a)
add_library(myutil STATIC ${srcs})

# 如果别人引用了我这个库，不需要你指定头文件，我这里帮你找到了。
target_include_directories(myutil PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
# 如果我不加上面这一行，那么所有引用我的库都要在他们的工程项目中CMakeLists手动指定头文件目录
```

`myutil/hello.cpp`
```cpp
#include "hello.h"  
#include <iostream>  
  
void sayHello() {  
    printf("Hello");  
}
```

`myutil/hello.h`
```cpp
#ifndef HELLO_H  
#define HELLO_H  
void sayHello();  
#endif
```


## 顶级目录（主程序）
`CMakeLists.txt`
```cmake
cmake_minimum_required(VERSION 3.25)
project(libdemo)
set(CMAKE_CXX_STANDARD 20)

add_executable(main main.cpp)

# 依赖库头文件位置 g++ main.cpp -I myutil/
#这里注释掉了是因为依赖包已经使用了target_include_directories命令帮我寻找了头文件。
#include_directories(myutil)

# 如果不想手动指定头文件位置，而是引入库就自动找头文件，那需要在库文件的CMakeLists中使用
# target_include_directories(依赖库名称 PUBLIC "${PROJECT_BINARY_DIR}")

# 添加这行才会编译子目录
add_subdirectory(myutil)


# 把可执行文件和库文件链接起来 g++ main.cpp -I MyListUtils
# 依赖什么文件，就要链接什么文件
target_link_libraries(main myutil)

```


`main.cpp`
```cpp
# 引入依赖库头文件，不需要指定目录，因为依赖库的CMakeLiss.txt调用了target_include_directories
#include "hello.h"  
  
int main() {  
    sayHello();  
}
```

## 运行
```shell 
G:\cmakeProject\libdemo\cmake-build-debug\main.exe
Hello
Process finished with exit code 0
```
静态库已经被编译进main.exe中，体积更大
![](Pasted%20image%2020231115195518.png)


## 动态库写法(依赖库与可执行文件分离)
由于dll文件和exe文件分离，我们需要指定dll生成目录到exe文件目录中，利用`set_target_properties`设置dll生成目录
`myutil/CMakeLists.txt`
```cmake
set(CMAKE_CXX_STANDARD 20)
# 当前目录下所有.c文件保存到srcs变量里面去
file(GLOB srcs CONFIGURE_DEPENDS
"${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

message(${srcs})

# 暴露自己：我是一个共享库
# 注意：Windows如果是动态库（SHARED)必须把库和exe文件放在同级目录！！
# 动态库 .so .dll
add_library(myutil SHARED ${srcs})

# 注意：Windows如果是静态库（STATIC)则没有要求
# 静态库 .a .lib
# add_library(myutil STATIC ${srcs})

# 如果别人引用了我这个库，不需要你指定头文件，我这里帮你找到了。
target_include_directories(myutil PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
# 如果我不加上面这一行，那么所有引用我的库都要在他们的工程项目中CMakeLists手动指定头文件目录

# Windows用户：动态库DLL文件生成到exe目录下
set_target_properties(myutil
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/
)

```

最终动态库文件dll和可执行文件exe在同级目录
![](Pasted%20image%2020231115193504.png)



## 排错：依赖库找不到
```
G:\cmakeProject\libdemo\cmake-build-debug\main.exe

Process finished with exit code -1073741515 (0xC0000135)
```

### 方案1：设置成静态库
`myutil/CMakeLists.txt`
```cmake
add_library(myutil STATIC ${srcs})
```


### 方案2：把依赖库放到和可执行文件的同目录下
`myutil/CMakeLists.txt`
```cmake

add_library(myutil SHARED ${srcs})

set_target_properties(myutil  
        PROPERTIES  
        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/  
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/  
)
```

## 总结 
- 子目录使用 addlibrary暴露自己，静态库STATIC；动态库SHARED要注意DLL文件生成位置。
- 顶级目录使用add_subdirectory(依赖库位置)编译依赖库，target_link_libraries并链接到可执行程序。
- 静态库会使得可执行程序体积更大，动态库需要指定生成目录。
