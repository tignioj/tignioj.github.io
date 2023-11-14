---
date: 2023-11-14T03:57:27.827Z
lastmod: 2023-11-14T03:57:27.827Z
categories:
  - 软件折腾
  - anki
title: Anki夜间模式图片颜色反转
draft: "false"
tags:
  - anki
series:
---

夜间模式下，白色背景图片过于刺眼，使用css样式使图片颜色反转

找到牌组->浏览->卡片，找到样式
![](Pasted%20image%2020231114120114.png)

在样式里面输入css，就可以看到右边图片颜色反转了。

```css
.night_mode img {

filter: invert(1); -webkit-filter:invert(1);

}
```


![](Pasted%20image%2020231114120205.png)




参考：[FIXED: Image colors inverting in night mode : r/Anki (reddit.com)](https://www.reddit.com/r/Anki/comments/mv2pq6/fixed_image_colors_inverting_in_night_mode/)