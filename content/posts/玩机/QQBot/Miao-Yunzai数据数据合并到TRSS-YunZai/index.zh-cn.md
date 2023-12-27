---
date: 2023-12-26T23:56:06.251Z
lastmod: 2023-12-26T23:56:06.251Z
categories:
  - 玩机
  - QQBot
title: Miao-Yunzai数据数据合并到TRSS-YunZai
draft: "false"
tags:
  - TRSS
  - Miao-Yunzai
  - redis
  - sqlite3
series:
---
当你MiaoYunzai和TRSS都跑了一段时间后，两个机器人都有了自己独立的数据，这时候简单的迁移是不行的。因此我们需要将MiaoYunzai的数据导出，并在TRSS-Yunzai中导入。
## 导出Miao-Yunzai用户数据
由于我是docker compose运行的MiaoYunzai，因此数据文件单独存储在了yunzai目录下
```
root@tignioj:/home/tignioj/dockercompose/yunzai/Miao-Yunzai/yunzai# ls -l
total 54692
drwxr-xr-x  2 root root     4096 Dec 26 22:28 config
drwxr-xr-x 15 root root     4096 Dec 15 19:38 data
drwxr-xr-x  2 root root     4096 Dec  4 03:32 genshin_config
drwxr-xr-x  2 root root     4096 Dec 26 16:42 logs
-rw-r--r--  1 root root 55977116 Dec 26 23:58 miao-data.zip
drwxr-xr-x  7 root root     4096 Dec 15 19:31 plugins
drwxr-xr-x  7 root root     4096 Dec  4 03:32 temp
root@tignioj:/home/tignioj/dockercompose/yunzai/Miao-Yunzai/yunzai# 
```

如果你不是docker跑的，那数据文件就在Miao-Yunzai 项目目录下。

### 进入MiaoYunzai的data目录，打包数据文件。
```
zip -r miao-data.zip config/ data/ logs/ temp/
```
### 必要文件说明
- conf 配置文件
- data 
	- db/data.db： SQLite数据库文件
	- icqq：登录设备信息
	- logs：日志文件
	- PlayerData: 保存的用户面板信息
	- face: 用户自定义表情

无需迁移plugins，到时候有缺的在TRSS-Yunzai下载即可。

### 数据库合并到TRSS-Yunzai
把Miao-Yunzai下data/db/data.db用Navicat打开
![](Pasted%20image%2020231227081144.png)

![](Pasted%20image%2020231227081841.png)

光标对着表，右键选择导出向导


![](Pasted%20image%2020231227081242.png)
选择DBase文件*.dbf
![](Pasted%20image%2020231227081404.png)
选择表格
![](Pasted%20image%2020231227081437.png)
选择所有字段
![](Pasted%20image%2020231227081450.png)
下一步
![](Pasted%20image%2020231227081507.png)
点击开始
![](Pasted%20image%2020231227081518.png)
会自动保存到桌面
![](Pasted%20image%2020231227081529.png)

### 导入SQLite表
在TRSS-Yunzai中找到data/db/data.db文件，并用Navicat打开
```
root@localhost:~/TRSS_AllBot/TRSS-Yunzai/data/db# ls
data.db 
```

同样的方法打开TRSS-yunzai下的数据库文件，打开User表，可以看到有178条记录
![](Pasted%20image%2020231227082006.png)
右键User表，选择导入向导
![](Pasted%20image%2020231227082127.png)
选择DBase文件
![](Pasted%20image%2020231227082140.png)
添加文件，选择我们从Miaoyunzai导出的数据文件
![](Pasted%20image%2020231227082206.png)![](Pasted%20image%2020231227082233.png)
![](Pasted%20image%2020231227082252.png)

接着下一步
![](Pasted%20image%2020231227082316.png)
继续
![](Pasted%20image%2020231227082327.png)

选择追加
![](Pasted%20image%2020231227082346.png)
点击开始，可以看到已添加748。
![](Pasted%20image%2020231227082402.png)
刷新一下，就可以看到有962条数据，表明User表导入完成。
![](Pasted%20image%2020231227082456.png)

同样的处理导入`MysUsers`，这里不再重复。
- 注：UserGames是空表，所以无需导入。


### 导出redis数据（保存了群排行信息）
找到`Miao-Yunzai/redis/data/redis.rdb` ，将其转换为aof文件。

转换方式1：第三方工具：`https://github.com/leonchen83/redis-rdb-cli`
下载后，执行
```
rct -f resp -s ./dump.rdb -o ./dump.aof
```

注：你不能直接合并两个rdb，否则[可能出现key冲突 ](https://github.com/leonchen83/redis-rdb-cli/issues/25)。

转换方式2：redis-cli方式（先挖坑）


### 总结导出了哪些文件
1. miao-data.zip (包含config/ data/ logs/ temp/)
2. 合并后的data/db/data.db数据
4. redis.aof数据



## 导入到TRSS

### 导入miao-data.zip
上传到TRSS服务器后，执行`unzip miao-data.zip`，把解压后的文件复制到TRSS-Yunzai对应的目录


### 导入合并后的data/db/data.db数据
将修改后的数据库上传到TRSS服务器，并覆盖`TRSS-Yunzai/data/db/data.db`。到这里SQLite数据合并完成。查看数据库内容得知，Users表不保存面板信息，而是保存用户的id，用户的面板信息保存在`~/TRSS_AllBot/TRSS-Yunzai/data/PlayerData/gs`。

### 导入redis数据
- 参考： https://developer.redis.com/explore/import/
执行tsab进入TRSS容器，选择附加功能-fish，进入终端，进入TRSS-Yunzai，

![](Pasted%20image%2020231227085607.png)

执行以下命令将aof文件导入到redis
```
cat dumpslm.aof |  redis-cli -p 6379 --pipe
```

### 教程结束
