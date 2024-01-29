---
date: 2024-01-21T06:07:02+08:00
lastmod: 2024-01-22T10:44:03+08:00
categories:
  - 玩机
  - 路由器
title: 小米路由器BE7000在docker中使用v2raya透明代理
draft: "false"
tags:
  - 科学上网
  - v2raya
series: 
---

## 创建v2raya容器

首先请开启ssh，否则无权限。插入usb存储后，安装docker并启动，管理界面安装与否无所谓，关键是你要能进ssh。连接小米路由器ssh终端后，进入usb目录，找到docker的执行文件路径,这里的usb-xxx具体取决于你的设备。

### docker执行文件目录添加到环境变量
一些有用的环境变量，从/etc/init.d/mi_docker上面复制的，粘贴到终端
```
DEVICE_UUID=$(uci -q get mi_docker.settings.device_uuid)
STORAGE_DIR=$(storage dump | grep -C3 "${DEVICE_UUID:-invalid-uuid}" | grep target: | awk '{print $2}')
STORAGE_SIZ=$(storage dump | grep -C3 "${DEVICE_UUID:-invalid-uuid}" | grep size: | awk '{printf "%d", $2/2}')
DOCKER_DIR="${STORAGE_DIR:=/not_exist_disk}/mi_docker"
DOCKER_VER="20.10.17"
DOCKER_MD5="f9b6570a174df41aec6b822fba7a17aa"
DOCKER_TGZ="$DOCKER_DIR/docker-$DOCKER_VER.tgz"
DOCKER_BIN="$DOCKER_DIR/docker-binaries"
```

你也可以把docker执行文件添加到当前终端的环境变量
```
export PATH=$PATH:$DOCKER_BIN
```

相当于
```
export PATH=$PATH:/mnt/usb-cc5b5b23/mi_docker/docker-binaries
```


创建一个v2raya配置目录
```
mkdir ${STORAGE_DIR}/docker/v2raya && cd ${STORAGE_DIR}/docker/v2raya
```

执行以下命令创建v2raya容器
```
docker run -d \
  --restart=always \
  --privileged \
  --network=host \
  --name v2raya \
  -e V2RAYA_LOG_FILE=/tmp/v2raya.log \
  -e V2RAYA_V2RAY_BIN=/usr/local/bin/v2ray \
  -e V2RAYA_NFTABLES_SUPPORT=off \
  -e IPTABLES_MODE=legacy \
  -v /lib/modules:/lib/modules:ro \
  -v /etc/resolv.conf:/etc/resolv.conf \
  -v ${STORAGE_DIR}/docker/v2raya:/etc/v2raya \
  mzz2017/v2raya
```

查看容器是否成功运行，看到`v2raya`的STATUS为UP状态表明重启已经成功创建并运行。
```
root@XiaoQiang:/mnt/usb-cc5b5b23/mi_docker/docker-binaries# ./docker ps
CONTAINER ID   IMAGE            COMMAND    CREATED         STATUS         PORTS     NAMES
1ba7ea87cb45   mzz2017/v2raya   "v2raya"   9 minutes ago   Up 9 minutes             v2raya
```

然后你就可以进入路由器的IP:2017 进入v2raya后台管理界面，首次需要创建账号和密码。导入自己的服务后，右上角设置开启透明代理即可。


```
root@XiaoQiang:/mnt/usb-cc5b5b23/mi_docker/docker-binaries# ps | grep docker
20021 root      1444 S    grep docker
21494 root     1601m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/dockerd --config-file=/tmp/dockerd/daemon.json
21496 root      711m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/opa-docker-authz -policy-file /var/run/docker/opa/authz.rego
21543 root     1446m S    containerd --config /mnt/usb-cc5b5b23/mi_docker/run/docker/containerd/containerd.toml --log-level warn
23255 root      687m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9001 -container-ip 172.17.0.2 -container-port 4050
23263 root      687m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/docker-proxy -proto tcp -host-ip :: -host-port 9001 -container-ip 172.17.0.2 -container-port 4050
23295 root      695m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/containerd-shim-runc-v2 -namespace moby -id eb28121beb78fec91bd92720c702cf6050130f51a32e2c63ee94001f1408bec8 -address /mnt
26090 root      695m S    /mnt/usb-cc5b5b23/mi_docker/docker-binaries/containerd-shim-runc-v2 -namespace moby -id 54e46e6e3ecf4643a2e158035fb8a88d8e4b9ca6df71888d8c5f219bc1df0e6c -address /mnt

```

##  docker错误排查

创建完容器后，发现小米路由器自带的web界面启动会报错`不可用,检测到已安装的docker文件缺失,请卸载docker后重新安装` ，为什么会这样呢？
这是因为mi_docker服务检测到我们挂载了不合理的目录，我们查看mi_docker的检测脚本
```
root@XiaoQiang:/etc/init.d# ./mi_docker check_integrity
root@XiaoQiang:/etc/init.d# echo $?
6
```
发现返回了数字6，这意味着什么？打开脚本看看

```
check_integrity() {
        local md5
        local file

        for file in $DOCKER_BIN_LIST; do
                md5=$(uci -q get "mi_docker.md5.${file//-/_}")
                check_file_md5 "${md5:-xxxx}" "$DOCKER_BIN/$file"
        done

        [ -n "$(check_mountpoint)" ] && exit 6

        return 0
}

```

如果 `check_mountpoint` 的结果是非空的（意味着检查挂载点的返回结果存在某些内容），那么退出当前的脚本或shell，并返回状态码 `6` ，继续追踪check_mountpoint函数
```

valid_mountpath() {
        local file="$1"
        local filter="$2"
        local sock="/var/run/docker.sock"

        cat < "$file" | jsonfilter -e "$filter" | cut -d: -f1 |
                while read -r path; do
                        real="$path"
                        [ "$path" != "$sock" ] && real=$(readlink -f "$path")

                        if ! echo "$real" | grep -qsE "^($STORAGE_DIR|$sock)"; then
                                logerr "$file mount source $path invalid"
                                echo 1
                                break
                        fi
                done
}

check_mountpoint() {
        find "$DOCKER_DIR/lib/docker/containers" -name "config.v2.json" |
                while read -r file; do
                        valid_mountpath "$file" '@.MountPoints.*.Spec.Source'
                done

        find "$DOCKER_DIR/lib/docker/containers" -name "hostconfig.json" |
                while read -r file; do
                        valid_mountpath "$file" '@.Binds.*'
                done
}

```

### valid_mountpath代码含义？

这个 `valid_mountpath` 函数在 Bash 脚本中定义，主要用于检查文件的挂载路径是否有效。我会逐步解释这个函数的细节。

1. `local file="$1"`：定义了一个局部变量 `file`，它的值被设定为函数的第一个参数。

2. `local filter="$2"`：定义了一个局部变量 `filter`，它的值被设定为函数的第二个参数。

3. `local sock="/var/run/docker.sock"`：定义了一个局部变量 `sock`，值被设定为 "/var/run/docker.sock”。

4. `cat < "$file" | jsonfilter -e "$filter"`：这个命令会读取 `file` 的内容，然后通过管道符 (`|`) 传递给 `jsonfilter` 命令。`jsonfilter` 用 `-e` 选项执行 `filter` 的内容。

5. `cut -d: -f1 |`：这个 `cut` 命令会将每行中的 `:` 分隔的第一个字段（`-f1`）取出。

6. `while read -r path; do`：这种结构用于处理管道传来的每一行数据，`read -r path` 表示将读取到的每一行数据赋值给变量 `path`，然后在 `do` 与 `done` 闭合的代码块中进行操作。

   - `[ "$path" != "$sock" ] && real=$(readlink -f "$path")`：如果 `path` 不等于 `sock`，那么使用 `readlink -f "$path"` 命令获取 `path` 的绝对路径并赋值给变量 `real`。
   
   - `if ! echo "$real" | grep -qsE "^($STORAGE_DIR|$sock)"; then`：这是一个判断结构，如果 `real` 不以 `$STORAGE_DIR` 或者 `$sock` 开始，那么就会执行 `{}` 闭合的代码块。
    
        - `logerr "$file mount source $path invalid"`：调用 `logerr` 函数（可能在脚本的其他地方定义），展示错误信息，提示文件的挂载源 `path` 是无效的。

        - `echo 1`：输出 `1`，表示检测到错误。

        - `break`：跳出 `while` 循环。


注意到如果 `real` 不以 `$STORAGE_DIR` 或者 `$sock` 开始就会报错，往上翻找到这个`STORAGE_DIR`，我们新建一个终端查看一下该变量

```
DEVICE_UUID=$(uci -q get mi_docker.settings.device_uuid)
STORAGE_DIR=$(storage dump | grep -C3 "${DEVICE_UUID:-invalid-uuid}" | grep target: | awk '{print $2}')
echo $STORAGE_DIR
```
可以看到其输出路径是 `/mnt/usb-cc5b5b23`，也就是说，一旦检测到容器有挂载到非usb目录的，都会自行报错。但是v2raya需要挂载很多系统的文件，因此解决办法只能通过修改mi_docker 的检测脚本。

## 添加启动脚本
在我尝试直接将check_integrity的首行代码添加return 0时候，发现重启后会被复原，于是只能在自启动脚本中修改，请通过此方法创建通用启动脚本 -> [index.zh-cn](../小米路由器BE7000开机自启通用脚本/index.zh-cn.md)

往startup_script()里面添加两行即可。

```
sed -i '/valid_mountpath() {/a return 0' /etc/init.d/mi_docker
/etc/init.d/mi_docker start
```
代码解释：sed找到"valid_mountpath() {"并在该行代码下面添加一行return 0，表示跳过检测，接着执行mi_docker start 启动docker