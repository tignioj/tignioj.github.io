---
date: 2024-01-21T12:44:52+08:00
lastmod: 2024-01-21T12:44:52+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器BE7000开机自启通用脚本
draft: "false"
tags:
  - 路由器
  - 小米
series:
---

## 使用防火墙方案设定自启动脚本

编辑如下内容
```
vim /data/startup_script.sh 
```

添加以下内容
```
#!/bin/sh
install() {
	# Add script to system autostart docker
	uci set firewall.startup_script=include
	uci set firewall.startup_script.type='script'
	uci set firewall.startup_script.path="/data/startup_script.sh"
	uci set firewall.startup_script.enabled='1'
	uci commit firewall
	echo -e "\033[32m  startup_script complete. \033[0m"
}
uninstall() {
    # Remove scripts from system autostart
    uci delete firewall.startup_script
    uci commit firewall
    echo -e "\033[33m startup_script has been removed. \033[0m"
}

startup_script() {
	# Put your custom script here.
	echo "Starting custom scripts..."
}

main() {
    [ -z "$1" ] && startup_script && return
    case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo -e "\033[31m Unknown parameter: $1 \033[0m"
        return 1
        ;;
    esac
}


main "$@"
```


给予可执行权限
```
chmod +x /data/startup_script.sh
```

安装自启动
```
/data/startup_script.sh install
```



执行install后，可以看到/etc/config/firewall添加了一些内容
```
config include 'startup_script'
        option type 'script'
        option path '/data/startup_script.sh'
        option enabled '1'
```

需要自启动什么命令，直接在startup_script() 里面添加即可，到这里教程结束，后面可以不看。




## 为什么不能使用传统的方法
### 修改路由器的/etc/init.d/下的脚本，重启后会恢复，怎么解决？
如果你对脚本做的更改在重新启动路由器后被撤消，这就意味着你可能在存储类型为tmpfs（临时文件系统）的目录下编辑文件，此类型文件系统会在每次重启时恢复到初始状态。对于在 OpenWRT 或类似固件的路由器，`/etc/init.d/` 目录就是这样一个目录。

解决此问题的一种方法是：

1. 将你的脚本保存在持久存储的地方，例如 /etc/config/, 或者如果有jffs文件系统可用，那就是 /jffs/.

2. 在系统启动的时候运行你的脚本，可以在 /etc/rc.local 文件中加入一行来调用你的脚本。`/etc/rc.local`会在系统启动的时候执行，并且在路由器重启后保持不变。

这是添加调用脚本的示例：

```bash
# Place your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
sh /etc/config/my_script.sh
exit 0
```

在这个例子中，my_script.sh 是你在 /etc/config/ 或 /jffs/ 中保存的脚本文件。

如此一来，即使你重启了路由器，你的脚本依然会在启动时运行，并且你对脚本做的修改也会被保存。


### /etc/rc.local执行的优先级是怎样的，能否在/etc/init.d/my_script 执行之前，修改/etc/init.d/my_script

在Linux系统中，`/etc/rc.local` 脚本通常是在所有的系统服务（包括在 `/etc/init.d/` 目录中的服务）启动完毕之后才被执行。所以，优先级上来说，`/etc/init.d/my_script` 需要先于 `/etc/rc.local` 执行。

若你想要在 `/etc/init.d/my_script` 脚本执行之前对其进行修改，那你可能需要考虑在某个具有更高执行优先级的服务的启动脚本中添加你的修改代码。这样当优先级较高的服务启动时，它可以首先执行你的修改。

在 Linux 系统的初始化过程中，`/etc/init.d/` 目录下的脚本会根据其文件名的字母顺序进行启动。例如，`/etc/init.d/a_script` 会先于 `/etc/init.d/b_script` 运行。因此，你可以通过调整文件名来调整服务的启动顺序。

然而，如果你的系统使用基于数字优先级的系统 (如 System V)，那你需要调整脚本文件名前的数字。比如说，文件 `S10network` 将在 `S20httpd` 之前运行。

需要注意的是，非常情况下，我们不应该更改系统启动过程的顺序，因为这可能导致不可预见的问题。强烈建议只有在明确知道自己在做什么的前提下才进行这样的操作。

### 修改/etc/rc.local，失败
```
# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

# start docker
sed -i '/valid_mountpath() {/a return 0' /etc/init.d/mi_docker
/etc/init.d/mi_docker start

exit 0
```
重启路由器看看，发现/etc/rc.local也被还原了?? 最后在网上找到一个解决方案 https://www.right.com.cn/forum/thread-8242939-1-1.html

### 根据auto_ssh.sh启动原理自定义启动脚本

通过观察auto_ssh.sh的install函数发现，创建自定义脚本的方式是通过firewall指定脚本启动，于是我们可以仿造一个。