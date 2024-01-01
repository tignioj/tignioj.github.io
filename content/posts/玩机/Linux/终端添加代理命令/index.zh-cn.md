---
date: 2023-11-14T04:16:32.583Z
lastmod: 2024-01-01T08:44:43+08:00
categories:
  - 玩机
  - Linux
title: 终端添加代理命令
draft: "false"
tags:
  - 代理
  - 终端
  - 科学上网
series: 
---
对于Linux，编辑 `vim ~/.bashrc` (如果你是`zsh`则 `vim ~/.zshrc`)
添加以下代码，将`PROXY_HOST`，`HTTP_PORT`，`HTTPS_PORT` 分别设置为你代理服务器的配置。
```shell
PROXY_HOST=localhost
HTTP_PORT=20171;
HTTPS_PORT=20172;
alias proxy="
    export http_proxy=${PROXY_HOST}:${HTTP_PORT};
    export https_proxy=${PROXY_HOST}:${HTTPS_PORT};"
alias unproxy="
    unset http_proxy;
    unset https_proxy;"
```

然后载入配置 `source ~/.bashrc`，此时输入`proxy`，自动为当前脚本环境添加了代理。输入env查看
```bash
tignioj@localhost:~$ env
https_proxy=localhost:20172
http_proxy=localhost:20171
```

检查代理是否成功连接： `curl https://www.google.com`
```
root@tignioj:~# curl -I https://www.google.com
HTTP/1.1 200 Connection established

HTTP/2 200
content-type: text/html; charset=ISO-8859-1
content-security-policy-report-only: object-src 'none';base-uri 'self';script-src 'nonce-r8hJzNdBHS2fQ7fJbeAZag' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
p3p: CP="This is not a P3P policy! See g.co/p3phelp for more info."
date: Mon, 01 Jan 2024 00:40:12 GMT
server: gws
x-xss-protection: 0
x-frame-options: SAMEORIGIN
expires: Mon, 01 Jan 2024 00:40:12 GMT
cache-control: private
set-cookie: 1P_JAR=2024-01-01-00; expires=Wed, 31-Jan-2024 00:40:12 GMT; path=/; domain=.google.com; Secure
```
如果要取消代理则输入`unproxy`



## proxy的GPT3.5解释
### ALL_PROXY是什么

`ALL_PROXY` 是一个环境变量，用于在终端中设置全局代理。通过设置 `ALL_PROXY`，你可以让终端中的所有网络请求都通过指定的代理服务器进行转发。

这个环境变量通常包含代理服务器的地址和端口号，具体的设置取决于你使用的代理协议。例如，如果你使用的是HTTP代理，那么 `ALL_PROXY` 可能会被设置成类似于 `http://proxy_server:proxy_port` 的形式。

以下是一个设置 `ALL_PROXY` 的示例：


```
export ALL_PROXY=http://your_proxy_server:proxy_port
```


这样设置后，终端中的所有网络请求都会通过指定的代理服务器进行传输，包括HTTP、HTTPS等协议。

需要注意的是，使用 `ALL_PROXY` 设置全局代理可能会影响到整个终端环境，包括系统命令、应用程序等。在某些情况下，可能需要注意避免影响到不需要代理的网络连接。

### 如果已经设置了http_proxy和https_proxy，还需要设置all_proxy吗

通常情况下，如果你已经设置了 `http_proxy` 和 `https_proxy`，就不需要额外设置 `ALL_PROXY`。`ALL_PROXY` 是一个通用性更强的环境变量，用于设置所有协议的代理，包括 HTTP、HTTPS、FTP 等。而 `http_proxy` 和 `https_proxy` 分别用于设置 HTTP 和 HTTPS 的代理。

一般来说，绝大多数应用程序和工具都会优先使用 `http_proxy` 和 `https_proxy` 这两个环境变量，而忽略 `ALL_PROXY`。如果你已经设置了 `http_proxy` 和 `https_proxy`，那么大多数情况下就足够了，不需要再设置 `ALL_PROXY`。

但是，某些特定的工具或应用程序可能会使用 `ALL_PROXY`，因此在特殊情况下，你可能需要根据具体情况来决定是否设置 `ALL_PROXY`。如果你的代理设置正常运作并满足你的需求，而没有使用 `ALL_PROXY`，那么就没有必要再额外设置它。