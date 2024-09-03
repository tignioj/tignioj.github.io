---
date: 2024-09-04T07:36:22+08:00
lastmod: 2024-09-04T07:36:22+08:00
categories:
  - 编程杂谈
  - 前端
  - Vuejs
title: Vuejs-KeepAlive失效问题
draft: "false"
tags:
  - Vuejs
series:
---
## 多余的空格导致失效

- 正常：
```html
<router-view v-slot="{ Component }">
  <keep-alive include="ConfigEditorPage,ScriptManagerPage">
	<component :is="Component" />
  </keep-alive>
</router-view>
```
- 仅第一个生效
```html
<router-view v-slot="{ Component }">
  <keep-alive include="ConfigEditorPage, ScriptManagerPage">
	<component :is="Component" />
  </keep-alive>
</router-view>
```

### 不正确的写法导致失效
奇怪的是，官方文档仅给出了keep-alive，但是却没有指出 component如何提供，查阅其他文档才得知Component来源于v-slot中的Component，也就是当前渲染的组件
- 正确：router-view包裹keep-alive
```html
<router-view v-slot="{ Component }">
	<keep-alive>
	  <component :is="Component" />
	</keep-alive>
</router-view>
```
- 错误：keep-alive包裹router-view
```html
<keep-alive>
  <router-view />
</keep-alive>
```

这种写法会给出警告
```
main.js:21  [Vue Router warn]: <router-view> can no longer be used directly inside <transition> or <keep-alive>.
Use slot props instead:

<router-view v-slot="{ Component }">
  <keep-alive>
    <component :is="Component" />
  </keep-alive>
</router-view>
```


## 参考
- https://juejin.cn/post/7098986605494894600 
- https://cn.vuejs.org/guide/built-ins/keep-alive