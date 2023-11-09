---
date: 2023-11-09T20:45:18.611Z
lastmod: 2023-11-09T22:25:12.511Z
categories:
  - 软件折腾
  - Obsidian
  - obsidian插件开发
title: obsidian插件开发-链接的显示问题
draft: "false"
tags:
  - obsidian插件
  - obsidian
series: 
---

# 问题
由于obsidian中插入的链接都是以文件名称作为显示，而hugo博客大部分页面都是index.zh-cn.md，真正的名称保存在front-matter以及父类名称里面。那么带来的问题就是所有插入的链接显示都是 index.zh-cn.md而不是真正的名称。

例如 `[index.zh-cn](../../用obsidian管理hugo文章小技巧/index.zh-cn.md)`, 显示效果就是 index.zh-cn


为了解决这个问题，我想到了两个办法。
## 在插入链接的时候，修改链接标题
obsidian按下`[[`时，会弹窗让你选择你要插入的文件，这个弹窗类对象我不清除具体是什么对象，但是参阅官方文档知道这是一个`SuggestModal`相关的窗口
```js
export abstract class SuggestModal<T> extends Modal implements ISuggestOwner<T> {
```
可以看到`SuggestModal`实现了`ISuggestOwner`接口，点进去看发现`ISuggestOwner`有两个方法, 在注释中我们可以看到 `selectSuggestion` 会在做出选择的时候被调用，也就是说我们插入链接的时候，这个方法就会被调用。

```js
export interface ISuggestOwner<T> {  
    /**  
     * Render the suggestion item into DOM.     * @public  
     */  
    renderSuggestion(value: T, el: HTMLElement): void;  
    /**  
     * Called when the user makes a selection.     * @public  
     */  
    selectSuggestion(value: T, evt: MouseEvent | KeyboardEvent): void;  
  
}
```
但是知道这个有什么用呢？对我们插入链接有什么帮助？当然有用！
知道了什么方法被调用意味我们可以偷天换日！把原本调用的方法换成我们自己的！

### js最基础的函数替换方法
js有个神奇的[apply()](https://www.w3schools.com/js/js_function_apply.asp)函数，它能够做到在不修改源函数的情况下处理参数。例如
```js
const obj = {  
    // obj1对象里面打印参数1  
    fun1 : (arg1)=>{ console.log(arg1); }  
}  
const origin_fun = obj.fun1; // 先拿到原始的函数fun1  
// 修改成我们自己的方法  
obj.fun1 = function (arg1) {  
    // 处理参数  
    arg1 = arg1 + ", world!"  
    // 调用原始方法, 第一个参数是调用的对象，后面是原始函数的参数，要用数组形式传进去  
    origin_fun.apply(obj, [arg1])  
}
```

对于`selectSuggestion`，里面有两个参数，一个是泛型`T`, 一个是`MouseEvent`，我们就可以写成下面这样
```js
// 先拿到原始的函数selectSuggestion
let orig_fn = this.app.workspace.editorSuggest.suggests[0].selectSuggestion;
// 再替换成我们自定义的函数
this.app.workspace.editorSuggest.suggests[0].selectSuggestion =  
    function (value, evt) {  
		console.log(value);// 处理参数
		// 调用原始函数，并传入原本需要的参数（数组形式传入）
		orig_fn.apply(this, [value, evt]);  
    }
```

为什么selectSuggestion 藏的这么深？obsidian官方文档中我没有查询到任何有关如何获取的方法，而是在社区论坛求助中得到了这位网友的指点 https://forum-zh.obsidian.md/t/topic/25546/6



## 不修改标题，而是修改显示效果（仅阅读模式生效）
官方示例 https://docs.obsidian.md/Plugins/Editor/Markdown+post+processing

点击右上角的书本图标进入阅读模式，通过`Ctrl + I` 找到链接的dom，发现链接里面是这样的
```html
<a class="internal-link" 
   data-href="../../../编程/Linux2/Ubuntu/Ubuntu安装Samba/index.zh-cn.md" 
   href="../../../编程/Linux2/Ubuntu/Ubuntu安装Samba/index.zh-cn.md" 
   target="_blank" rel="noopener">index.zh-cn</a>
```

那我们只需要获取到这个internal-link，把值设置成`data-href`里面的`index.zh-cn.md`的上一级目录，也就是该文档的名称。
用正则表达式把 `../../../编程/Linux2/Ubuntu/Ubuntu安装Samba/index.zh-cn.md` 保留 Ubuntu安装Samba 用到组匹配，一个括号一组，那么


- `.*\/` 对应了 `../../../编程/Linux2/Ubuntu/` ，因为没有加问好，所以会贪婪匹配
- `(.*)` 对应了`Ubuntu安装Samba`的内容
- `\/index.zh-cn.md` 对应了`/index.zh-cn.md`，其中`/`用了反义符号

写成代码就是
```js
this.registerMarkdownPostProcessor(  
    (element, context) => {  
    const links = element.findAll(".internal-link")  
       for(const link of links) {  
          const s=link.getAttribute("data-href")  
          if (s) {  
             const ns = s.replace(/.*\/(.*)\/index.zh-cn.md/g, "$1")  
             link.setText(ns)  
          }  
       }  
});
```

# 总结
- 第一种方法虽然能够利用suggestion来替换标题，但是只能在首次插入的时候替换，当我们在obsidian中修改文档标题名称时候，并不会再次触发suggestion引发修改（路径会修改，但是标题不会，因为修改的方法是在suggestion中定义的），因此有一定的弊端。
- 第二种方法只能在阅读模式下生效，我们发布文档到hugo之后仍然显示的是index.zh-cn.md，除非手动修改hugo的渲染方式`render-link.html`
