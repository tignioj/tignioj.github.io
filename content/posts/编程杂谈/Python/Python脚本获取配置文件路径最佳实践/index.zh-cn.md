---
date: 2024-01-23T13:34:56+08:00
lastmod: 2024-01-23T13:34:56+08:00
categories:
  - 编程杂谈
  - Python
title: Python脚本获取配置文件路径最佳实践
draft: "true"
tags: []
series: []
---

## 获取配置文件
例如项目结构
```
project|
	config.yaml
	utils|
		config_utils.py
```

其中`config_utils.py`获取`config.yaml`方法
```
import yaml,os  
cwd = os.path.dirname(__file__)   # 当前py文件所在目录
config_path = os.path.join(cwd, "../config.yaml")
```
用`os.path.dirname(__file__)`而不是`os.getcwd()`的原因是：`getcwd` 获取的是python执行命令所在的目录，而不是文件所在目录。

## 读取配置文件
```
with open(config_path, "r",encoding="utf8") as stream:  
    try:  
        config = yaml.safe_load(stream)  
    except yaml.YAMLError as exc:  
        print(exc)
```


## 针对不同系统读取不同的配置
config.yaml
```yaml
windows:
  onedrive_path: 'G:\\OneDrivePersonal\\OneDrive\\Documents'
  smb_path: '//192.168.30.1/INTEL_SS_DSC2KW256G8(9a7c)/文档/'
macos:
  onedrive_path: ''
  smb_path: ""

```


```
import yaml, os, platform  
  
  
def _get_config_file():  
    _cwd = os.path.dirname(__file__)  
    config_path = os.path.join(_cwd, "../config.yaml")  
    with open(config_path, "r", encoding="utf8") as stream:  
        try:  
            config_all = yaml.safe_load(stream)  
            pf = platform.system()  
            if pf == "Windows":  
                return config_all['windows']  
            elif pf == "Darwin":  
                return config_all['macos']  
  
        except yaml.YAMLError as exc:  
            print(exc)  
  
  
config = _get_config_file()
```