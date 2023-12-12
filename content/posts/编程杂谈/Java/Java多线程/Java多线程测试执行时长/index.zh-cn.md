---
date: 2023-12-12T02:53:15.373Z
lastmod: 2023-12-12T02:53:15.373Z
categories:
  - 编程杂谈
  - Java
  - Java多线程
title: Java多线程测试执行时长
draft: "false"
tags:
  - Java
  - 多线程
series:
---
 
## 多个线程执行程序时，如何统计总共用时？
可以使用`CountDownLatch` ，指定线程数量。
当latch调用await时阻塞，直到所有的线程都执行latch.countDown();
例如下面的例子，300个线程
```java
    @Test  
    public void testIdWorker() throws InterruptedException {  
        int threadCount = 300;  
        //latch.await()等待300个线程都执行完成countDown后,才能继续执行  
        CountDownLatch latch = new CountDownLatch(threadCount);  
  
        Runnable task = ()-> {  
            for (int i = 0; i < 100; i++) {  
                long l = redisIdWorker.nextId("order");  
                System.out.println(l);  
            }  
            // 每个任务都要countDown  
            latch.countDown();  
        };  
        long begin = System.currentTimeMillis();  
        for (int i = 0; i < threadCount; i++) {  
            es.submit(task);  
        }  
        latch.await();  
        long end = System.currentTimeMillis();  
        System.out.println("time=" + (end-begin));  
    }  
}
```


学习来源
https://www.bilibili.com/video/BV1cr4y1671t?p=49&vd_source=cdd8cee3d9edbcdd99486a833d261c72

