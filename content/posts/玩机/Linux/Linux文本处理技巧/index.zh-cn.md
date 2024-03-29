---
date: 2023-12-05T16:41:09.025Z
lastmod: 2024-01-22T11:21:18+08:00
categories:
  - 玩机
  - Linux
title: Linux文本处理技巧
draft: "false"
tags:
  - 文本处理
series: 
---
查看多行文本, 以 << EOF开头，EOF结尾，并且结尾的EOF前面不要有空格
```bash
cat << EOF
aaa
bbb
ccc
EOF
```
将文本输出到文件a.txt
```bash
cat << EOF > a.txt
aaa
bbb
ccc
EOF
```
通过类似的方法我们还可以做一些交互的输入，例如sudo输入密码
```bash
sudo su root << EOF
123456
EOF
```

如果希望内容不要视为脚本，而是视为纯文本，用单引号包围`EOF`
https://stackoverflow.com/a/9870274
```shell
cat << 'EOF' > a.txt
a=hello
echo a
EOF
cat a.txt
```
输出
```
a=hello
echo a
```