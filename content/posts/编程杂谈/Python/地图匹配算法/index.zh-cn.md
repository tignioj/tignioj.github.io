---
date: 2024-03-20T22:52:05+08:00
lastmod: 2024-03-20T22:52:05+08:00
categories:
  - 编程杂谈
  - Python
title: 地图匹配算法
draft: "true"
tags:
  - SURF
series:
---

## SURF

- 基本原理和代码： https://docs.opencv.org/4.x/df/dd2/tutorial_py_surf_intro.html
看不出有什么具体用途

- surf简单的示例，9分钟， https://www.youtube.com/watch?v=PBTrwymDVCg

- [Feature Detection and Matching + Image Classifier Project | OPENCV PYTHON](https://www.youtube.com/watch?v=nnH55-zD38I)
	- 有原理讲解

视频开头使用了ORB而不是surf，是因为ORB免费而SURF申请了专利，使用要支付年费。

```python
import cv2 as cv  
import numpy as np  
# flag=0 as gray image  
img1 = cv.imread("../resources/map/mmap.png", 0)  
img2 = cv.imread("../resources/map/combined_image.png", 0)  
  
# cv.imshow("img1",img1)  
# cv.namedWindow('img2', cv.WINDOW_NORMAL)  
# cv.imshow("img2",img2)  
  
# ORB免费，SURF收费  
orb = cv.ORB.create(nfeatures=1000)  
# des是描述器，用来存储图像中的特征  
kp1, des1 = orb.detectAndCompute(img1, None)  
kp2, des2 = orb.detectAndCompute(img2, None)  
print(des1.shape)  
  
# imgKp1 = cv.drawKeypoints(img1, kp1, None, color=(0,0,255))  
# imgKp2 = cv.drawKeypoints(img2, kp2, None, color=(0,255,0))  
  
  
# bf使用k邻近算法  
bf = cv.BFMatcher()  
matches = bf.knnMatch(des1, des2, k=2)  
  
good = []  
for m, n in matches:  
    # 把距离短的特征存进去  
    if m.distance < 0.75 * n.distance:  
        good.append([m])  
  
print(len(good))  
# flag=2 如何展示图片  
img3 = cv.drawMatchesKnn(img1, kp1, img2, kp2, good, None, flags=2)  
# cv.namedWindow("Matches", cv.WINDOW_GUI_EXPANDED)  
# cv.imshow("Matches", img3)  
cv.imwrite("../resources/matches.png", img3)  
  
# cv.imshow("imgKp1", imgKp1)  
# cv.namedWindow('imgKp2', cv.WINDOW_NORMAL)  
# cv.imshow("imgKp2", imgKp2)  
  
cv.waitKey(0)  
cv.destroyAllWindows()
```

但是实测下来，效果并不是很好。虽然SURF收费，但是可以手动编译opencv免费使用。
### 编译opencv-python
- 问题： https://answers.opencv.org/question/221044/option-build_opencv_python3-missing-from-cmake-gui/

- 问题： https://answers.opencv.org/question/237756/at-my-wits-end-with-opencv-build-from-source-please-help/

https://github.com/opencv/opencv_contrib

使用cmake-gui编译opencv时，发现没有build_opencv_python3选项。则把anaconda的python先从环境变量中删除，防止cmake-gui检测到anaconda的python，然后官网直接下载最新版python让cmake检测到即可。


![](Pasted%20image%2020240321062844.png)

为了使用surf算法，请勾选这个选项，然后配置OPENCV_EXTRA_MODULES_PATH，接着再次点击配置
![](Pasted%20image%2020240321062933.png)

指定python版本编译是没用d的，版本必须要和在系统安装的相同，否则无法使用。
![](Pasted%20image%2020240321072941.png)


在vs中选择Release，然后找到INSTALL右键点击生成。
![](Pasted%20image%2020240321063048.png)



## 命令行编译python-opencv指定anaconda虚拟环境
在opencv根目录下创建一个mybuild文件夹，执行以下命令。注意，自行删除掉换行和反斜杠


```
cmake ../ -D CMAKE_BUILD_TYPE=Release \  
-D CMAKE_INSTALL_PREFIX=G:/cmakeProject/opencv_python39_bin_cli/install \  
-D WITH_TBB=ON \  
-D ENABLE_FAST_MATH=1 \  
-D CUDA_FAST_MATH=1 \  
-D WITH_CUBLAS=1 \  
-D WITH_CUDA=ON \  
-D BUILD_opencv_cudacodec=OFF \  
-D WITH_CUDNN=ON \  
-D OPENCV_DNN_CUDA=ON \  
-D CUDA_ARCH_BIN="5.3 6.0 6.1 7.0 7.5 8.0 8.6" \  
-D CUDA_GENERATION=Auto \  
-D WITH_V4L=ON \  
-D WITH_QT=OFF \  
-D WITH_OPENGL=ON \  
-D WITH_GSTREAMER=ON \  
-D OPENCV_GENERATE_PKGCONFIG=ON \  
-D OPENCV_PC_FILE_NAME=opencv.pc \  
-D OPENCV_ENABLE_NONFREE=ON \  
-D OPENCV_EXTRA_MODULES_PATH=G:\cmakeProject\opencv_contrib\modules \  
-D BUILD_opencv_python2=OFF \  
-D BUILD_opencv_python3=ON \  
-D PYTHON_VERSION=39 \  
-D PYTHON_DEFAULT_EXECUTABLE=G:\software\anaconda\envs\opencvNoneFree \  
-D PYTHON3_EXECUTABLE=G:\software\anaconda\envs\opencvNoneFree \  
-D PYTHON3_PACKAGES_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages \  
-D PYTHON3_INCLUDE_DIR=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages/numpy/core/include \  
-D OPENCV_PYTHON3_INSTALL_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages/numpy/core/include/dist-packages \  
-D PYTHON3_NUMPY_INCLUDE_DIRS=G:\software\anaconda\envs\opencvNoneFree\Lib\site-packages\numpy\core\include \  
-D BUILD_EXAMPLES=OFF \  
-D INSTALL_PYTHON_EXAMPLES=OFF \  
-D INSTALL_C_EXAMPLES=OFF \
```



```
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

换成一行后
```
cmake ../ -D CMAKE_BUILD_TYPE=Release  -D OPENCV_ENABLE_NONFREE=ON  -D OPENCV_EXTRA_MODULES_PATH=G:\cmakeProject\opencv_contrib\modules  -D BUILD_opencv_python2=OFF  -D BUILD_opencv_python3=ON  -D PYTHON_VERSION=39  -D PYTHON_DEFAULT_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe  -D PYTHON3_EXECUTABLE=G:/software/anaconda/envs/opencvNoneFree/python.exe  -D PYTHON3_PACKAGES_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages  -D PYTHON3_INCLUDE_DIR=G:/software/anaconda/envs/opencvNoneFree/include  -D PYTHON3_LIBRARY=G:/software/anaconda/envs/opencvNoneFree/libs/python39.lib  -D OPENCV_PYTHON3_INSTALL_PATH=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages  -D PYTHON3_NUMPY_INCLUDE_DIRS=G:/software/anaconda/envs/opencvNoneFree/Lib/site-packages/numpy/core/include  -D BUILD_EXAMPLES=OFF  -D INSTALL_PYTHON_EXAMPLES=OFF  -D INSTALL_C_EXAMPLES=OFF
```

终端切换到你要安装到的虚拟环境，然后执行cmake编译命令，执行完成后，Python3的信息
![](Pasted%20image%2020240412231704.png)


可以看到mybuild生成visual studio项目，用visual stuio 2022 打开它，选择Release，找到CmakeTargets找到Install选择生成


## SURF vs SITF
https://www.bilibili.com/video/BV1DM4y1A7yJ/?vd_source=cdd8cee3d9edbcdd99486a833d261c72