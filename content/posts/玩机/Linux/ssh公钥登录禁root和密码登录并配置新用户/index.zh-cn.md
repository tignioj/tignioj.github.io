---
date: 2023-12-13T03:38:47.177Z
lastmod: 2023-12-13T03:38:47.177Z
categories:
  - 玩机
  - Linux
title: ssh公钥登录禁root和密码登录并配置新用户
draft: "false"
tags:
  - ssh
series: 
---
## 创建新用户
useradd帮助
```shell
[root@localhost learn_redis]# useradd
Usage: useradd [options] LOGIN
       useradd -D
       useradd -D [options]

Options:
  -b, --base-dir BASE_DIR       base directory for the home directory of the
                                new account
  -c, --comment COMMENT         GECOS field of the new account
  -d, --home-dir HOME_DIR       home directory of the new account
  -D, --defaults                print or change default useradd configuration
  -e, --expiredate EXPIRE_DATE  expiration date of the new account
  -f, --inactive INACTIVE       password inactivity period of the new account
  -g, --gid GROUP               name or ID of the primary group of the new
                                account
  -G, --groups GROUPS           list of supplementary groups of the new
                                account
  -h, --help                    display this help message and exit
  -k, --skel SKEL_DIR           use this alternative skeleton directory
  -K, --key KEY=VALUE           override /etc/login.defs defaults
  -l, --no-log-init             do not add the user to the lastlog and
                                faillog databases
  -m, --create-home             create the user's home directory
  -M, --no-create-home          do not create the user's home directory
  -N, --no-user-group           do not create a group with the same name as
                                the user
  -o, --non-unique              allow to create users with duplicate
                                (non-unique) UID
  -p, --password PASSWORD       encrypted password of the new account
  -r, --system                  create a system account
  -R, --root CHROOT_DIR         directory to chroot into
  -P, --prefix PREFIX_DIR       prefix directory where are located the /etc/* files
  -s, --shell SHELL             login shell of the new account
  -u, --uid UID                 user ID of the new account
  -U, --user-group              create a group with the same name as the user
  -Z, --selinux-user SEUSER     use a specific SEUSER for the SELinux user mapping

```

root模式下：
```
useradd tignioj
```

设置密码
```
passwd tignioj
```

创建用户的home目录
```
mkdir /home/tignioj
```
授予目录权限给新用户
```
chown -R tignioj:tignioj /home/tignioj
```
设定默认shell为bash
```
su tignioj
chsh -s /bin/bash
```

以上命令可以用一行代替：`useradd -m tignioj -s /bin/bash -p "my_password"`

```shell
[root@localhost:~]# useradd -m user1 -s /bin/bash -p "my_password"
[root@localhost:~]# ls -la /home/user1/
total 12
drwx------. 2 tignioj tignioj  62 Dec 12 22:46 .
drwxr-xr-x. 4 root  root   34 Dec 12 22:46 ..
-rw-r--r--. 1 tignioj tignioj  18 Nov 24  2021 .bash_logout
-rw-r--r--. 1 tignioj tignioj 193 Nov 24  2021 .bash_profile
-rw-r--r--. 1 tignioj tignioj 231 Nov 24  2021 .bashrc
[root@localhost:~]#
```


## 授予用户sudo权限

```
visudo
```
假如你输入visudo进入了nano编辑器，可以通过`Ctrl` + `X`退出编辑器。
由于个人习惯vim，[修改编辑器为vim](https://askubuntu.com/questions/539243/how-to-change-visudo-editor-from-nano-to-vim)。

```
root@localhost:~# update-alternatives --config editor  
There are 4 choices for the alternative editor (providing /usr/bin/editor).  
  
Selection Path Priority Status  
------------------------------------------------------------  
0 /bin/nano 40 auto mode  
1 /bin/ed -100 manual mode  
2 /bin/nano 40 manual mode  
* 3 /usr/bin/vim.basic 30 manual mode  
4 /usr/bin/vim.tiny 15 manual mode  
  
Press <enter> to keep the current choice[*], or type selection number: 3  
root@localhost:~#
```
添加tignioj的sudo权限
```
# User privilege specification  
root ALL=(ALL:ALL) ALL  
tignioj ALL=(ALL:ALL) ALL
```

## 允许公钥登录并禁密码和远程root登录
禁止密码登录和远程登录
```
vim /etc/ssh/sshd_config
```
找到`PermitRootLogin`和`PasswordAuthentication`，设置为`no`
```
PermitRootLogin no  
PasswordAuthentication no
```

还需要设置`PubkeyAuthentication` 为yes，否则登录会报错 `Permission Denied (Public key)`
```
PubkeyAuthentication yes  
RSAAuthentication yes
```

## 配置新用户登录公钥
客户端，先生成公钥文件
```
➜ ~ ✗ ssh-keygen  
Generating public/private rsa key pair.  
Enter file in which to save the key (C:\Users\lili/.ssh/id_rsa):  
Enter passphrase (empty for no passphrase):  
Enter same passphrase again:  
Your identification has been saved in C:\Users\lili/.ssh/id_rsa.  
Your public key has been saved in C:\Users\lili/.ssh/id_rsa.pub.  
The key fingerprint is:  
SHA256:OYxuMybC8nztn9ShSyhew9ybczOeB9fEH6wudvlAM3Y lili@DESKTOP-9IJNN32  
The key's randomart image is:  
+---[RSA 3072]----+  
| |  
| |  
| .. |  
| o . oo |  
| . S . B.E.|  
| . + o +..+.= .|  
|. o o.% = .o... |  
| + o.*.*.=++.+. |  
| o.....*+++o .. |  
+----[SHA256]----
```

先切换到新用户，在home目录下创建.ssh文件夹
```
su tignioj
mkdir .ssh
cd .ssh
```
创建authorized_keys文件，输入公钥。公钥是你登录的客户端.ssh目录下的`id_rsa.pub`里面的文件内容。
```
vim authorized_keys
```

设置`authorized_keys`文件的权限为0600
```
chmod 0600 authorized_keys
```

查看
```
tignioj@localhost:~/.ssh$ ls -la  
total 20  
drwxrwxr-x 2 tignioj tignioj 4096 Dec 13 11:37 .  
drwxr-xr-x 5 tignioj tignioj 4096 Dec 13 11:38 ..  
-rw------- 1 tignioj tignioj 742 Dec 13 11:37 authorized_keys  
-rw------- 1 tignioj tignioj 2622 Dec 13 11:37 id_rsa  
-rw-r--r-- 1 tignioj tignioj 585 Dec 13 11:37 id_rsa.pub  
tignioj@localhost:~/.ssh$
```

重启sshd
```
systemctl restart sshd
```



## 远程登录

windows terminal登录
```
ssh tignioj@ip:port 
```

xshel7登录
注意要导入客户端（非linux服务器）的.ssh/id_rsa 文件
![](Pasted%20image%2020231213122733.png)


参考：
https://www.cnblogs.com/my-first-blog-lgz/p/16385745.html
https://blog.csdn.net/weixin_43693967/article/details/130789425