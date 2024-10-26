---
date: 2024-10-26T21:18:11+08:00
lastmod: 2024-10-26T21:18:11+08:00
categories:
  - 编程杂谈
  - 机器学习
  - 目标检测
  - YOLO学习
title: YOLOV8模型训练
draft: "false"
tags:
  - YOLO
series:
---


## 准备数据结构和目录


按照一定比例分割train,test,val数据集:
```python
import os
import random
from tqdm import tqdm
# 指定 images 文件夹路径
image_dir = "datasets/JPEGImages"
# 指定 labels 文件夹路径
label_dir = "datasets/labels"
dest_dir = "sp_datasets"
# 创建一个空列表来存储有效图片的路径
valid_images = []
# 创建一个空列表来存储有效 label 的路径
valid_labels = []
# 遍历 images 文件夹下的所有图片
for image_name in os.listdir(image_dir):
    # 获取图片的完整路径
    image_path = os.path.join(image_dir, image_name)
    # 获取图片文件的扩展名
    ext = os.path.splitext(image_name)[-1]
    # 根据扩展名替换成对应的 label 文件名
    label_name = image_name.replace(ext, ".txt")
    # 获取对应 label 的完整路径
    label_path = os.path.join(label_dir, label_name)
    # 判断 label 是否存在
    if not os.path.exists(label_path):
        # 删除图片
        os.remove(image_path)
        print("deleted:", image_path)
    else:
        # 将图片路径添加到列表中
        valid_images.append(image_path)
        # 将label路径添加到列表中
        valid_labels.append(label_path)
        # print("valid:", image_path, label_path)
# 遍历每个有效图片路径
for i in tqdm(range(len(valid_images))):
    image_path = valid_images[i]
    label_path = valid_labels[i]
    # 随机生成一个概率
    r = random.random()
    # 判断图片应该移动到哪个文件夹
    # train：valid：test = 7:3:1
    if r < 0.1:
        # 移动到 test 文件夹
        destination = os.path.join(dest_dir,"test")
        if not os.path.exists(destination):
            os.mkdir(destination)
            os.mkdir(destination + "/images")
            os.mkdir(destination + "/labels")
    elif r < 0.2:
        # 移动到 valid 文件夹
        destination = os.path.join(dest_dir, "valid")
        if not os.path.exists(destination):
            os.mkdir(destination)
            os.mkdir(destination + "/images")
            os.mkdir(destination + "/labels")
    else:
        # 移动到 train 文件夹
        destination = os.path.join(dest_dir, "train")
        if not os.path.exists(destination):
            os.mkdir(destination)
            os.mkdir(destination + "/images")
            os.mkdir(destination + "/labels")
    # 生成目标文件夹中图片的新路径
    image_destination_path = os.path.join(destination, "images", os.path.basename(image_path))
    # 移动图片到目标文件夹
    os.rename(image_path, image_destination_path)
    # 生成目标文件夹中 label 的新路径
    label_destination_path = os.path.join(destination, "labels", os.path.basename(label_path))
    # 移动 label 到目标文件夹
    os.rename(label_path, label_destination_path)
print("valid images:", valid_images)
# 输出有效label路径列表
print("valid labels:", valid_labels)

# 推理： yolo task=detect mode=predict model=yolov8n.pt conf=0.25 source='ultralytics/assets/bus.jpg'
# 训练： yolo task=detect mode=train model=yolov8n.pt data=tree.yaml epochs=100 imgsz=640 resume=True workers=2
# 验证:yolo val model="weights/best.pt" data=tree.yaml
# yolo task=detect mode=train model=runs/detect/train12/weights/last.pt epochs=500 imgsz=640 resume=True workers=2
```


数据集描述文件

tree.yaml
```yml
path: G:\PyCharmProgram\YOLOlearn\yolov8demo\mytreedemo\sp_datasets  
train: train/images  
test: test/images  
val: valid/images  
nc: 1  
names:  
  0: tree
```


## 训练
https://docs.ultralytics.com/modes/train/#__tabbed_1_2

### 命令行训练
```
yolo task=detect mode=train model=yolov8n.pt data=tree.yaml epochs=100
```

### 代码训练
注意在windows中一定要设置workers=0否则会报错
```python
from ultralytics import YOLO  
  
# Load a model  
model = YOLO("yolov8n.pt")  # load a pretrained model (recommended for training)  
  
# Train the model  
results = model.train(data="tree.yaml",workers=0, epochs=100, batch=16)  
print(results)
```

## 指定参数配置文件训练

如何从配置文件中加载默认的参数，可以在命令行运行以下命令复制一份默认配置
```
yolo copy-cfg
```
输出如下
```
(yolov8_learn) PS G:\PyCharmProgram\YOLOlearn\yolov8demo\mytreedemo> yolo copy-cfg                                                          
G:\software\anaconda\envs\yolov8_learn\Lib\site-packages\ultralytics\cfg\default.yaml copied to G:\PyCharmProgram\YOLOlearn\yolov8demo\mytreedemo\default_copy.yaml
Example YOLO command with this new custom cfg:
    yolo cfg='G:\PyCharmProgram\YOLOlearn\yolov8demo\mytreedemo\default_copy.yaml' imgsz=320 batch=8

```
在命令行执行的目录多了个`default_copy.yaml`，修改其中的
- model: yolov8n.pt
- data: 'tree.yaml'  
- workers: 0

```yaml
# Ultralytics YOLO 🚀, AGPL-3.0 license  
# Default training settings and hyperparameters for medium-augmentation COCO training  
  
task: detect # (str) YOLO task, i.e. detect, segment, classify, pose  
mode: train # (str) YOLO mode, i.e. train, val, predict, export, track, benchmark  
  
# Train settings -----------------------
model: 'yolov8n.pt' # (str, optional) path to model file, i.e. yolov8n.pt, yolov8n.yaml  
data: 'tree.yaml' # (str, optional) path to data file, i.e. coco128.yaml  
epochs: 100 # (int) number of epochs to train for  
time: # (float, optional) number of hours to train for, overrides epochs if supplied  
patience: 100 # (int) epochs to wait for no observable improvement for early stopping of training  
batch: 16 # (int) number of images per batch (-1 for AutoBatch)  
imgsz: 640 # (int | list) input images size as int for train and val modes, or list[w,h] for predict and export modes  
save: True # (bool) save train checkpoints and predict results  
save_period: -1 # (int) Save checkpoint every x epochs (disabled if < 1)  
cache: False # (bool) True/ram, disk or False. Use cache for data loading  
device: # (int | str | list, optional) device to run on, i.e. cuda device=0 or device=0,1,2,3 or device=cpu  
workers: 0 # (int) number of worker threads for data loading (per RANK if DDP)
...
```

执行以下命令开始训练
```
yolo cfg=default_copy.yaml 
```

## 常见问题
- 页面文件太小，无法完成操作
	- 修改训练参数的workers=0
	- 修改系统设置，增大虚拟内存
- data尽量设置为相对目录，而非绝对目录，因为这个路径会被写入到~/AppData/Roaming/Ultralytics/settings.yaml
- 调整数据集目录后再次训练，需要删除~/AppData/Roaming/Ultralytics/settings.yaml

如果data设置为绝对路径，生成的settings.yaml如下，会发现datasets
```
settings_version: 0.0.4
datasets_dir: E:\game\datasets
weights_dir: E:\game\PGPL-2.3\weights
runs_dir: E:\game\PGPL-2.3\runs
uuid: 84819f1765575cc3070a89ea807447bffb0479d2ea45004964c480f92248cc81
sync: true
api_key: ''
clearml: true
comet: true
dvc: true
hub: true
mlflow: true
neptune: true
raytune: true
tensorboard: true
wandb: true

```


更新：关于路径的问题，设置一个path就行，不会影响



## 参考
- https://www.bilibili.com/video/BV1j24y1577q?spm_id_from=333.788.videopod.sections&vd_source=cdd8cee3d9edbcdd99486a833d261c72
-  含笔记： https://www.bilibili.com/video/BV1fY411y7Xq?spm_id_from=333.788.recommend_more_video.0&vd_source=cdd8cee3d9edbcdd99486a833d261c72