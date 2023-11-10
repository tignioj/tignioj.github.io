---
date: 2023-11-06T20:49:29.656Z
lastmod: 2023-11-06T21:40:34.438Z
categories:
  - 软件折腾
  - Obsidian
  - obsidian插件开发
title: obsidian插件开发-沉浸式查找obsidian事件
draft: "true"
tags:
  - obsidian
  - obsidian插件
  - 事件
  - 监听
series:
---
# 需求
当插入链接的时候，我需要修改标题，那么我就要获取插入链接的事件。
有哪些事件呢？
我翻开官方文档的editor https://docs.obsidian.md/Plugins/Editor/Editor
发现有这样一段代码 
```js
const view = this.app.workspace.getActiveViewOfType(MarkdownView); 
	// Make sure the user is editing a Markdown file. 
	if (view) { const cursor = view.editor.getCursor(); 
	// ... 
	}
```
发现这里有两个对象，一个是MarkdownView，一个是view.editor
那么要获取事件，应该要从这俩对象入手。
我们查看这两对象的源码



于是打开控制台，分别测试谁能够调用registEvent()方法，发现view可以调用。



那么问题来了，registEvent里面究竟有什么事件呢？参数应该传什么？IDE给出的提示是EventRef
![](Pasted%20image%2020231107045509.png)

按下鼠标左键进入源码，自动进入了obsidian.d.ts文件中定义的这个方法

>  WebStrom点击`Ctrl + 鼠标左键` 可以查看光标上选择的方法的源码，如果你不是用IDE，也可以自己去github上[查看obsidian.d.ts源码](https://github.com/obsidianmd/obsidian-api/blob/master/obsidian.d.ts)， 按下Ctrl+F搜索`registerEvent`

```js
/**  
 * @public  
 */  
export class Component {
	/**  
	 * Registers an event to be detached when unloading * @public  
	 */  
	registerEvent(eventRef: EventRef): void;  
	/**  
	 * Registers an DOM event to be detached when unloading * @public  
	 */
}
```
那么这个`EventRef`又是什么？继续寻找发现是一个接口
```js
/**  
 * @public  
 */  
export interface EventRef {  
}
```
也就是说，任何实现了该接口的对象，都能作为事件传入`registerEvent()`中。
比如在Vault中，有如下事件，事件具体做什么注释已经说清楚。 
>   `on() : 接口` 这是方法实现接口？还没深入了解，暂时先不管。

```js
export class Vault extends Events {
	/**  
	 * Called when a file is created. 
	 * This is also called when the vault is first loaded for each existing file 
	 * If you do not wish to receive create events on vault load, register your event handler inside {@link Workspace.onLayoutReady}.  
	 * @public */
	 on(name: 'create', callback: (file: TAbstractFile) => any, ctx?: any): EventRef;  
	/**  
	 * Called when a file is modified. 
	 * @public 
	 * */
	 on(name: 'modify', callback: (file: TAbstractFile) => any, ctx?: any): EventRef;  
	/**  
	 * Called when a file is deleted. 
	 * @public 
	 * */
	 on(name: 'delete', callback: (file: TAbstractFile) => any, ctx?: any): EventRef;  
	/**  
	 * Called when a file is renamed. 
	 * @public 
	 * */
	 on(name: 'rename', callback: (file: TAbstractFile, oldPath: string) => any, ctx?: any): EventRef;
}
```

我们可以通过这些带有: EventRef 的方法中，里面的参数name得知这些对象都有什么事件提供监听。
我在WorkSpace中找到了有关editor的事件
```js
export class Workspace extends Events {
	/**
     * Triggered when the user opens the context menu on an editor.
     * @public
     */
    on(name: 'editor-menu', callback: (menu: Menu, editor: Editor, info: MarkdownView | MarkdownFileInfo) => any, ctx?: any): EventRef;
    /**
     * Triggered when changes to an editor has been applied, either programmatically or from a user event.
     * @public
     */
    on(name: 'editor-change', callback: (editor: Editor, info: MarkdownView | MarkdownFileInfo) => any, ctx?: any): EventRef;
    /**
     * Triggered when the editor receives a paste event.
     * Check for `evt.defaultPrevented` before attempting to handle this event, and return if it has been already handled.
     * Use `evt.preventDefault()` to indicate that you've handled the event.
     * @public
     */
    on(name: 'editor-paste', callback: (evt: ClipboardEvent, editor: Editor, info: MarkdownView | MarkdownFileInfo) => any, ctx?: any): EventRef;
    /**
     * Triggered when the editor receives a drop event.
     * Check for `evt.defaultPrevented` before attempting to handle this event, and return if it has been already handled.
     * Use `evt.preventDefault()` to indicate that you've handled the event.
     * @public
     */
    on(name: 'editor-drop', callback: (evt: DragEvent, editor: Editor, info: MarkdownView | MarkdownFileInfo) => any, ctx?: any): EventRef;

    /**
     * @public
     */
    on(name: 'codemirror', callback: (cm: CodeMirror.Editor) => any, ctx?: any): EventRef;
}
```

令人沮丧的是，我们MarkDownView并没有提供任何事件监听，继续查看它的父类TextFileView，同样没有！

于是我就想，能不能直接监听WorkSpace事件呢？
我们在WorkSpace中找到一个奇怪的方法，其中有个CodeMirror.Editor，这是否意味着所有的Editor的事件都会被这个方法监听到？
```js
/**  
 * @public 
 **/
 on(name: 'codemirror', callback: (cm: CodeMirror.Editor) => any, ctx?: any): EventRef;
```

点进去看看，发现跳转到了其他文件index.d.ts
```js
/**
 * Methods prefixed with doc. can, unless otherwise specified, be called both on CodeMirror (editor) instances and
 * CodeMirror.Doc instances. Thus, the Editor interface extends DocOrEditor defining the common API.
 */
interface Editor extends DocOrEditor {
    /** Tells you whether the editor currently has focus. */
    hasFocus(): boolean;
```

往下拉发现也有Event相关的代码
```js
on<T extends keyof EditorEventMap>(eventName: T, handler: EditorEventMap[T]): void;  
on<K extends DOMEvent & keyof GlobalEventHandlersEventMap>(  
    eventName: K,  
    handler: (instance: Editor, event: GlobalEventHandlersEventMap[K]) => void,  
): void;
```

进入这个EventMap发现不得了，居然有这么多事件，可是这些应该怎么调用呢？
```js
interface EditorEventMap {  
    change: (instance: Editor, changeObj: EditorChange) => void;  
    changes: (instance: Editor, changes: EditorChange[]) => void;  
    beforeChange: (instance: Editor, changeObj: EditorChangeCancellable) => void;  
    cursorActivity: (instance: Editor) => void;  
    keyHandled: (instance: Editor, name: string, event: Event) => void;  
    inputRead: (instance: Editor, changeObj: EditorChange) => void;  
    electricInput: (instance: Editor, line: number) => void;  
    beforeSelectionChange: (instance: Editor, obj: EditorSelectionChange) => void;  
    viewportChange: (instance: Editor, from: number, to: number) => void;  
    swapDoc: (instance: Editor, oldDoc: Doc) => void;  
    gutterClick: (instance: Editor, line: number, gutter: string, clickEvent: Event) => void;  
    gutterContextMenu: (instance: Editor, line: number, gutter: string, contextMenuEvent: MouseEvent) => void;  
    focus: (instance: Editor, event: FocusEvent) => void;  
    blur: (instance: Editor, event: FocusEvent) => void;  
    scroll: (instance: Editor) => void;  
    refresh: (instance: Editor) => void;  
    optionChange: (instance: Editor, option: keyof EditorConfiguration) => void;  
    scrollCursorIntoView: (instance: Editor, event: Event) => void;  
    update: (instance: Editor) => void;  
    renderLine: (instance: Editor, lineHandle: LineHandle, element: HTMLElement) => void;  
    overwriteToggle: (instance: Editor, overwrite: boolean) => void;  
}
```
还有DocOrEditor 这个接口更是丰富，几乎涵盖了所有编辑文档的方法，由于代码太多，我挑选了一个看起来跟我们需求类似的方法。


```js
/** Create a new document that's linked to the target document. Linked documents will stay in sync (changes to one are also applied to the other) until unlinked. */
        linkedDoc(options: {
            /**
             * When turned on, the linked copy will share an undo history with the original.
             * Thus, something done in one of the two can be undone in the other, and vice versa.
             */
            sharedHist?: boolean | undefined;
            from?: number | undefined;
            /**
             * Can be given to make the new document a subview of the original. Subviews only show a given range of lines.
             * Note that line coordinates inside the subview will be consistent with those of the parent,
             * so that for example a subview starting at line 10 will refer to its first line as line 10, not 0.
             */
            to?: number | undefined;
            /** By default, the new document inherits the mode of the parent. This option can be set to a mode spec to give it a different mode. */
            mode?: string | ModeSpec<ModeSpecOptions> | undefined;
        }): Doc;
```


# 未完待续。。。