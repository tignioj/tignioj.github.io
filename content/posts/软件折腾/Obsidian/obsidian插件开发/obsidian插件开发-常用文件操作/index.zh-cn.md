---
date: 2023-11-05T16:55:11.038Z
lastmod: 2023-11-07T06:29:37.693Z
categories:
  - 软件折腾
  - Obsidian
  - obsidian插件开发
title: obsidian插件开发-常用文件操作
draft: "false"
tags:
  - obsidian
  - obsidian插件
---

目录结构如图所示
![](Pasted%20image%2020231106010926.png)

# 一、文件操作
## 创建文件
```js
/**
 * @public
 */
create(path: string, data: string, options?: DataWriteOptions): Promise<TFile>;
```
示例：在仓库根目录创建`1.md`，内容为`hello`
```js
this.app.vault.create("1.md", "hello");
```
示例：在仓库根的demo目录创建`ok.md`，内容为`world`
> 注意：目录不存在会报错
```js
this.app.vault.create("demo/ok.md", "hello");
```

## 重命名文件

调用`fileManager`可以让obsidian自动更新里面的链接！

```js
    export class FileManager {
    /**
     * Rename or move a file safely, and update all links to it depending on the user's preferences.
     * @param file - the file to rename
     * @param newPath - the new path for the file
     * @public
     */
    renameFile(file: TAbstractFile, newPath: string): Promise<void>;
    }
```
示例：修改 仓库根目录下的`1.md`为`2.md`
```js
const f = this.app.vault.getAbstractFileByPath("1.md")
this.app.fileManager(f, "2.md")
```

如果仅仅修改文件名称可以调用`this.app.vault.rename()`方法
## 获取所有文件
```js
/**
 * @public
 */
getFiles(): TFile[];
```
示例：获取所有文件
![](Pasted%20image%2020231106011657.png)

## 获取指定目录的文件列表
```js
/**
 * @public
 */
getAbstractFileByPath(path: string): TAbstractFile | null;
```

示例：获取posts下的所有文件
>	`TAbstractFile`虽然没有`children`这个属性，但是却能够调用，很奇怪？请查阅

```js
this.app.vault.getAbstractFileByPath("content/posts").children
```
![](Pasted%20image%2020231106011354.png)
这段代码在obsidian的控制台上可以直接运行，然而当我们呢调用`npm run build` 的时候缺报错了.

经过查阅源码得知，`TAbstractFile`确实没有`children`属性，但是在运行过程中，控制台自动转换成了 `TFolder`对象，所以没有报错，然而编译的时候却难以确定到底是`TFolder`还是`TFile`，因此我们需要手动强转
`TAbstractFile`属性 继承于`TAbstractFile`
```js
/**
 * @public
 */
export abstract class TAbstractFile {
    /**
     * @public
     */
    vault: Vault;
    /**
     * @public
     */
    path: string;
    /**
     * @public
     */
    name: string;
    /**
     * @public
     */
    parent: TFolder;

}

```

`TFile`继承于`TAbstractFile
```js
/**
 * @public
 */
export class TFile extends TAbstractFile {
    /**
     * @public
     */
    stat: FileStats;
    /**
     * @public
     */
    basename: string;
    /**
     * @public
     */
    extension: string;

}
```

`TFile`和`TFolder`继承于`TAbstractFile`，因此他们都可以调用`TAbstractFile`的方法，同时拥有自己独特的方法，而`children`是`TFolder`独特的方法，因此我们将其需要转换成`TFolder`
```js
/**  
 * @public */export class TFolder extends TAbstractFile {  
    /**  
     * @public     */    children: TAbstractFile[];  
  
    /**  
     * @public     */    isRoot(): boolean;  
}
```


示例：获取指定目录下的所有目录，封装成字符串数组并返回
```js
/**  
 ** @returns 获取系列，即content/series/下一级的所有目录名称。  
 */  
getSeries() :Series[] {  
  
    const p = this.app.vault?.getAbstractFileByPath("content/series")  
    console.log(p);  
    // <TFolder>变量名，强制转换
    const series = (<TFolder>this.app.vault?.getAbstractFileByPath(  
       "content/series"))?.children  
  
    const arr = new Array<Series>();  
    series.forEach((item : any) => {  
       arr.push({title: item.name, description: item.name})  
    });  
    console.log(arr)  
    return arr;  
}
```


# 二、文件夹操作

## 获取当前仓库系统目录
```js
this.app.vault.adapter.basePath
```
![](Pasted%20image%2020231106011106.png)

## 创建文件夹

```js
/**
 * @public
 */
createFolder(path: string): Promise<void>;
```

示例：在仓库根目录下创建名称为hello的文件夹
```
this.app.vault.createFolder("hello");
```
结果：


		|仓库
		|hello


示例：创建多层目录
```
this.app.vault.createFolder("a/b/c");
```

结果：

		|仓库
		|a
			|b
				|c



# 结束语

在开发过程中遇到各种问题，可以去官网 [obsidian-api](https://github.com/obsidianmd/obsidian-api/tree/bde556afa033e909ebfb9fcee8f5ef288276f78f) 查看源码`obsidian-api/obsidian.d.ts` 获取帮助



参考：
[Vault - Developer Documentation (obsidian.md)](https://docs.obsidian.md/Plugins/Vault)
[obsidian-api/obsidian.d.ts at bde556afa033e909ebfb9fcee8f5ef288276f78f · obsidianmd/obsidian-api (github.com)](https://github.com/obsidianmd/obsidian-api/blob/bde556afa033e909ebfb9fcee8f5ef288276f78f/obsidian.d.ts#L2735)