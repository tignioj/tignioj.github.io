---
date: 2024-06-24T03:17:29+08:00
lastmod: 2024-06-24T03:17:29+08:00
categories:
  - 编程杂谈
  - Python
title: 指定conda环境编译opencv
draft: "false"
tags:
  - opencv
  - SIFT
series:
---
## 下载visual studio 2022

- vs下载链接： [Visual Studio: 面向软件开发人员和 Teams 的 IDE 和代码编辑器 (microsoft.com)](https://visualstudio.microsoft.com/zh-hans/)

## 下载安装cmake
- cmake下载链接 [Download CMake](https://cmake.org/download/)


## 下载opencv以及opencv-contrib源代码
- opencv: [Releases - OpenCV](https://opencv.org/releases/)
- opencv-contrib: [opencv/opencv_contrib: Repository for OpenCV's extra modules (github.com)](https://github.com/opencv/opencv_contrib)

下载完成后解压。

## 使用cmake命令生成visual studio项目
当系统的环境变量检测到python时，使用cmake-gui会自动识别python环境，但是有时候我们想要指定python环境，就不能用cmake-gui了，本人尝试了几次未能成功指定，于是只能使用cmake命令行。
### 指定conda环境

- 参考： https://gist.github.com/raulqf/f42c718a658cddc16f9df07ecc627be7

创建conda环境
```
conda create -n opencvCompile python==3.9
```
安装numpy 
```
pip install numpy
```

安装完成后，找到numpy的路径的include文件夹，例如我的是在 
```
G:\software\anaconda\envs\opencvNoneFree\Lib\site-packages\numpy\core\include
```
而有的可能在
```
G:\software\anaconda\envs\opencvNoneFree\Lib\site-packages\numpy\_core\include
```
区别在于`core` 和 `_core` ，具体是哪个取决于该目录下是否有`include` 文件夹

### 准备编译命令
在opencv源代码根目录下创建一个`mybuild`文件夹，并准备以下命令。

> 注意：自行删除掉换行和反斜杠

```shell
cmake ../ -D CMAKE_BUILD_TYPE=Release \
-D OPENCV_ENABLE_NONFREE=ON \
-D OPENCV_EXTRA_MODULES_PATH=G:\cmakeProject\opencv_contrib\modules \
-D BUILD_opencv_python2=OFF \
-D BUILD_opencv_python3=ON \
-D PYTHON_VERSION=39 \
-D PYTHON_DEFAULT_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe \
-D PYTHON3_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe \
-D PYTHON3_PACKAGES_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages \
-D PYTHON3_INCLUDE_DIR=G:/software/anaconda/envs/opencvNoneFree/include \
-D PYTHON3_LIBRARY=G:/software/anaconda/envs/opencvNoneFree/libs/python39.lib \
-D OPENCV_PYTHON3_INSTALL_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages \
-D PYTHON3_NUMPY_INCLUDE_DIRS=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages/numpy/core/include \
-D BUILD_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D INSTALL_C_EXAMPLES=OFF \
```

需要指定的参数：
- OPENCV_EXTRA_MODULES_PATH:  opencv-contrib源代码的目录
- PYTHON_DEFAULT_EXECUTABLE: 指定的虚拟环境的python.exe可执行文件路径
- PYTHON3_EXECUTABLE：指定的虚拟环境的python.exe可执行文件路径
- PYTHON3_PACKAGES_PATH： 虚拟环境的包目录
- PYTHON3_INCLUDE_DIR
- PYTHON3_LIBRARY
- OPENCV_PYTHON3_INSTALL_PATH
- PYTHON3_NUMPY_INCLUDE_DIRS：numpy的include目录

其他参数
- OPENCV_ENABLE_NONFREE：一些需要编译才能使用的算法，例如SIFT、SURF


换成一行后
```
cmake ../ -D CMAKE_BUILD_TYPE=Release  -D OPENCV_ENABLE_NONFREE=ON  -D OPENCV_EXTRA_MODULES_PATH=G:\cmakeProject\opencv_contrib\modules  -D BUILD_opencv_python2=OFF  -D BUILD_opencv_python3=ON  -D PYTHON_VERSION=39  -D PYTHON_DEFAULT_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe  -D PYTHON3_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe  -D PYTHON3_PACKAGES_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages  -D PYTHON3_INCLUDE_DIR=G:/software/anaconda/envs/opencvNoneFree/include  -D PYTHON3_LIBRARY=G:/software/anaconda/envs/opencvNoneFree/libs/python39.lib  -D OPENCV_PYTHON3_INSTALL_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages  -D PYTHON3_NUMPY_INCLUDE_DIRS=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages/numpy/core/include  -D BUILD_EXAMPLES=OFF  -D INSTALL_PYTHON_EXAMPLES=OFF  -D INSTALL_C_EXAMPLES=OFF
```


## 打开visual studio进行编译
打开mybuild下的OpenCV.sln，在第二行的标签栏中选择`Release`，然后找到`解决方案资源管理器`中 `CmakeTargets` 下的`INSTALL`，右键选择`生成`，即可开始编译，大约持续10几分钟。
