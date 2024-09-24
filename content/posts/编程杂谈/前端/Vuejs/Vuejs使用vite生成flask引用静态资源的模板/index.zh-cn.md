---
date: 2024-09-24T21:00:52+08:00
lastmod: 2024-09-24T21:00:52+08:00
categories:
  - 编程杂谈
  - 前端
  - Vuejs
title: Vuejs使用vite生成flask引用静态资源的模板
draft: "false"
tags:
  - Vuejs
  - Flask
  - vite
series:
---

## 问题描述
vuejs使用vite执行npm run build的时候，生成falsk支持的格式，例如

```html

<!-- <script type="module" crossorigin src="/assets/index-C0LpkD3K.js"></script>-->  
<script type="module" src="{{ url_for('static', filename='assets/index-C0LpkD3K.js') }}"></script>  
  
<!-- <link rel="stylesheet" crossorigin href="/assets/index-Dub40aXx.css">-->  
<link rel="stylesheet" href="{{ url_for('static', filename='assets/index-Dub40aXx.css') }}">

```


## 解决方式一：生成清单
```js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  build: {
    manifest: true, // 启用 manifest 选项
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name]-[hash].js',
        chunkFileNames: 'assets/[name]-[hash].js',
        assetFileNames: 'assets/[name]-[hash].[ext]',
      },
    },
  },
});
```


这样构建的时候，dist目录就会多出一个清单
- .vite/manifest.js
```json
{  
  "index.html": {  
    "file": "assets/index-C0VM6xLP.js",  
    "name": "index",  
    "src": "index.html",  
    "isEntry": true,  
    "css": [  
      "assets/index-DOMhM5mM.css"  
    ]  
  }  
}
```

然后，在 Flask 模板中使用 manifest.json 文件来引用静态资源：
```html
{% with manifest = url_for('static', filename='manifest.json') %}
{% set assets = manifest | tojson %}
{% endwith %}

<script type="module" src="{{ url_for('static', filename=assets['index.js']) }}"></script>
<link rel="stylesheet" href="{{ url_for('static', filename=assets['index.css']) }}">
```

## 解决方式二：编写插件直接修改模板

在项目根目录创建一个js文件
- vite-plugin-flask.js
```js
export default function flaskPlugin() {
    return {
        name: 'vite-plugin-flask',
        transformIndexHtml(html, { bundle }) {
            // 获取生成的文件名
            const jsFile = Object.keys(bundle).find(file => file.endsWith('.js'));
            const cssFile = Object.keys(bundle).find(file => file.endsWith('.css'));

            // 替换 HTML 中的引用
            return html
                .replace(
                    /<script type="module" crossorigin src="\/assets\/.*\.js"><\/script>/,
                    `<script type="module" src="{{ url_for('static', filename='${jsFile}') }}"></script>`
                )
                .replace(
                    /<link rel="stylesheet" crossorigin href="\/assets\/.*\.css">/,
                    `<link rel="stylesheet" href="{{ url_for('static', filename='${cssFile}') }}">`
                );
        }
    };
}
```

在 vite.config.js中导入并使用我们刚刚编写的插件
```js
import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import flaskPlugin from './vite-plugin-flask'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    flaskPlugin(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
```


项目index.html
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <link rel="icon" href="/favicon.ico">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MiniMap-GUI</title>
  </head>
  <body>
    <div id="app"> </div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

生成后：
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <link rel="icon" href="/favicon.ico">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MiniMap-GUI</title>
    <script type="module" src="{{ url_for('static', filename='assets/index-C0VM6xLP.js') }}"></script>
    <link rel="stylesheet" href="{{ url_for('static', filename='assets/index-DOMhM5mM.css') }}">
  </head>
  <body>
    <div id="app"> </div>
  </body>
</html>

```