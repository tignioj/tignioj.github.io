---
date: 2023-11-15T15:25:59.990Z
lastmod: 2023-11-15T15:31:22.336Z
categories:
  - 编程杂谈
  - CLION
title: CLION实时模板调用groovy脚本生成随机数组
draft: "false"
tags:
  - groovy
  - CLION
series: 
description: CLION实时模板使用groovyScript()命令调用groovy脚本生成随机数组
---
## 编写groovy文件

tools.groovy

```groovy
def len= _1.substring(1) as int 
// _1表示传进来的第一个参数，截取了第一个字母，后面就都是数字了。
def str="";
random = new Random();
for(i in 1..len){
    if(i<len) str+=random.nextInt(100) + ","; //100以内的随机数
    else str += random.nextInt(100);
}
return str;
```

## 编写实时模板

右键复制文件绝对路径
![](Pasted%20image%2020231115232653.png)

![](Pasted%20image%2020231115232711.png)

使用函数`groovyScript("脚本绝对路径", 参数1, 参数2…)`

其中我们在第一个参数位置传入了`variableForIteration()` 表示获取数组名称

例如`int A11[]`，此时获取的参数就是`A11`,并作为字符串的形式传入到groovy到`_1`变量中。

数组名称要包括长度才能在groovy脚本中决定生成多少个随机数据

```c
groovyScript("/Users/xxx/CLionProjects/MyProject/tools.groovy", variableForIteration());
```

注意：Windows绝对路径要使用双反斜杠\\

```c
groovyScript("G:\\\\ClionProject\\\\datastructures-c\\\\tools.groovy", variableForIteration());
```

确定生效区域
![](Pasted%20image%2020231115232750.png)
## 调用模板

先写出 `int A11[]=ranarr`按下Tab按键就可以生成了。

注意我在groovy脚本中获取数组长度的方式是截取了第一个字母后面的数据的，因此数组名称必须由单个字母和数字组成。你可以自己调整。

![](Pasted%20image%2020231115232823.png)


![](Pasted%20image%2020231115232843.png)


参考：
- [Live template variables | IntelliJ IDEA Documentation (jetbrains.com)](https://www.jetbrains.com/help/idea/template-variables.html#predefined_functions)
- [https://www.tutorialspoint.com/groovy/groovy_substring.htm](https://www.tutorialspoint.com/groovy/groovy_substring.htm)