---
date: 2024-09-05T06:29:01+08:00
lastmod: 2024-09-05T06:29:01+08:00
categories:
  - 编程杂谈
  - 前端
  - Vuejs
title: Vuejs使用ace-editor自动补全
draft: "false"
tags:
  - Vuejs
  - 自动补全
series:
---
### 导入ace
```
import ace from 'ace-builds'
ace.config.set('basePath', '/node_modules/ace-builds/src-min-noconflict');
```

### 导入语言工具，两种写法
```
// 写法1
import extTool from 'ace-builds/src-noconflict/ext-language_tools';  
ace.config.setModuleUrl('ace/ext/language_tools', extTool);

// 写法2
import extTool from 'ace-builds/src-noconflict/ext-language_tools';
```

### 创建div、绑定、设置主题和语言

注意一定要写高度，否则可能看不见编辑器
```html
<script setup>
...

// 自动补全选项
const aceOptions = ref({  
  enableBasicAutocompletion: true,  
  enableSnippets: true,  
  enableLiveAutocompletion: true,  
})

onMounted(()=> {  
  editor.session.setMode("ace/mode/c_cpp");   // 设置语言
  editor.setTheme('ace/theme/monokai');  // 设置主题 
  editor.setOptions(aceOptions.value);  
  editor.completers = [customCompleter]  // 设置自定义自动补全
})
</script>

<template>
<div id="editor10" style="width: 100%; height: 200px"></div>
</template>
```

### 自定义补全
```js
// 自定义补全
const customCompleter = {  
  getCompletions: function(editor, session, pos, prefix, callback) {  
    const completions = [  
      {caption: "print", value: "print", meta: "keyword"},  
      {caption: "if", value: "if", meta: "keyword"},  
      {caption: "else", value: "else", meta: "keyword"},  
      {caption: "function", value: "function", meta: "keyword"},  
    ];  
    callback(null, completions);  
  }  
};
```


### 最终效果
![](Pasted%20image%2020240905063609.png)

