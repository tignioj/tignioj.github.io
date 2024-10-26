---
date: 2024-10-26T18:38:05+08:00
lastmod: 2024-10-26T18:38:05+08:00
categories:
  - 编程杂谈
  - 机器学习
  - 目标检测
  - YOLO学习
title: YOLOV8如何训练自己的数据
draft: "false"
tags:
  - YOLO
  - 数据标注
series:
---

## 数据准备



## 图片标注

### 本地标注:labelimg


### 在线标注make sense（也可以本地部署）
支持导入预训练模型辅助标注， https://github.com/SkalskiP/make-sense
但是需要先将yolov5模型(不支持v8)转换为tensorflowjs模型

```
conda activate yolov5
pip install tensorflowjs==2.8.5 
python export --weight your_best.pt --include tfjs
```


#### 本地部署make-sense
npm安装方式报错了，只好使用docker。windows安装docker，下载make scense源码
```
git clone https://github.com/SkalskiP/make-sense.git
```
官方给出的下一步骤是直接构建镜像，但是在windows上面，Dockerfile不使用EXPOSE会无法暴露容器的镜像，于是需要先在Dockerfile中添加一行`EXPOSE 3000`

- Dockerfile
```
FROM node:16.16.0
RUN apt-get update && apt-get -y install git && rm -rf /var/lib/apt/lists/*
COPY ./ /make-sense
RUN cd /make-sense && \
  npm install
WORKDIR /make-sense
EXPOSE 3000
ENTRYPOINT ["npm", "run", "dev"]
```

执行构建命令，先进入源码目录再构建
```
cd make-sense

# Build Docker Image
docker build -t make-sense -f docker/Dockerfile .

```
运行容器
```
# Run Docker Image as Service
docker run -dit -p 3000:3000 --restart=always --name=make-sense make-sense

# Get Docker Container Logs
docker logs make-sense
```
然后打开浏览器就能打开数据标注网站了。


## 公开数据集
https://public.roboflow.com



参考视频: https://www.bilibili.com/video/BV1GM4y1m7nm?spm_id_from=333.788.videopod.sections&vd_source=cdd8cee3d9edbcdd99486a833d261c72