---
date: 2024-09-05T06:29:01+08:00
lastmod: 2024-09-07T15:52:03+08:00
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
```js
import ace from 'ace-builds'
ace.config.set('basePath', '/node_modules/ace-builds/src-min-noconflict');
```

### 导入语言工具，两种写法
```js
// 写法1
import extTool from 'ace-builds/src-noconflict/ext-language_tools';  
ace.config.setModuleUrl('ace/ext/language_tools', extTool);

// 写法2
import extTool from 'ace-builds/src-noconflict/ext-language_tools';
```

注意：`ace.config.set('basePath'xxx` 会导致vuejs无法打包，因此改用下列写法
```js
import ace  from 'ace-builds'  
import extTool from 'ace-builds/src-noconflict/ext-language_tools';  
import modeC_Cpp from 'ace-builds/src-noconflict/mode-c_cpp?url';  
import monokai from "ace-builds/src-noconflict/theme-monokai?url";  
  
ace.config.setModuleUrl('ace/ext/language_tools', extTool);  
ace.config.setModuleUrl("ace/mode/c_cpp", modeC_Cpp);  
ace.config.setModuleUrl("ace/theme/monokai", monokai);
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
这种写法会覆盖掉原来的自动补全
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

onMounted(()=> {  
  ...
  editor.completers = [customCompleter]  // 设置自定义自动补全
})
```

如果你想在自带的补全基础上添加自己的补全，则用下面的方法
- 官方例子： [ace/demo/autocompletion.html at master · ajaxorg/ace (github.com)](https://github.com/ajaxorg/ace/blob/master/demo/autocompletion.html)
```js
onMounted(()=> {  
  // editor.completers = [customCompleter]  
  const langTools = ace.require('ace/ext/language_tools');  
  langTools.addCompleter(customCompleter)  
})
```


## 最终效果
![](Pasted%20image%2020240905063609.png)

## 拼音补全中文

首先下载拼音库[pinyin-pro](https://pinyin-pro.cn/)，文档： https://pinyin-pro.cn/use/pinyin.html
```
npm install pinyin-pro
```

根据中文生成补全map
```js
const character_arr = ['你好', '世界', '测试']  
const character_pinyin_map_arr = []  
character_arr.forEach(item=> {  
  character_pinyin_map_arr.push(  
      {caption: pinyin(item, {'toneType':'none'}), value: item, meta: item}  
  )  
})
```
把map加进去
```js
const customCompleter = {  
  getCompletions: function(editor, session, pos, prefix, callback) {  
    const completions = generateCompletions()  
    callback(null, completions);  
  }
};
```



### 参考
- https://github.com/ajaxorg/ace/wiki/How-to-enable-Autocomplete-in-the-Ace-editor 如何开启自动补全
- https://github.com/ajaxorg/ace/issues/4597
- https://github.com/CarterLi/vue3-ace-editor#breaking-change
- https://stackoverflow.com/questions/13545433/autocompletion-in-ace-editor
- https://stackoverflow.com/questions/24651222/misspelled-ace-editor-options
- https://github.com/ajaxorg/ace/wiki/Configuring-Ace  功能对应要导入的库