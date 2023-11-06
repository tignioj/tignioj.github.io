warning: in the working copy of 'content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发-文件操作/index.zh-cn.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'content/posts/软件折腾/Obsidian/obsidian插件开发/obsidian插件开发（一）入门/index.zh-cn.md', LF will be replaced by CRLF the next time Git touches it
[1mdiff --git "a/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221-\346\226\207\344\273\266\346\223\215\344\275\234/index.zh-cn.md" "b/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221-\346\226\207\344\273\266\346\223\215\344\275\234/index.zh-cn.md"[m
[1mindex dcd44b2..6a1b459 100644[m
[1m--- "a/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221-\346\226\207\344\273\266\346\223\215\344\275\234/index.zh-cn.md"[m
[1m+++ "b/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221-\346\226\207\344\273\266\346\223\215\344\275\234/index.zh-cn.md"[m
[36m@@ -6,7 +6,7 @@[m [mtags:[m
   - obsidian[m
   - obsidian插件[m
   - api[m
[31m-lastmod: 2023-11-05T16:55:25.902Z[m
[32m+[m[32mlastmod: 2023-11-05T17:18:37.225Z[m
 categories:[m
   - 软件折腾[m
   - Obsidian[m
[1mdiff --git "a/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221\357\274\210\344\270\200\357\274\211\345\205\245\351\227\250/index.zh-cn.md" "b/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221\357\274\210\344\270\200\357\274\211\345\205\245\351\227\250/index.zh-cn.md"[m
[1mindex b28b729..76ebc67 100644[m
[1m--- "a/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221\357\274\210\344\270\200\357\274\211\345\205\245\351\227\250/index.zh-cn.md"[m
[1m+++ "b/content/posts/\350\275\257\344\273\266\346\212\230\350\205\276/Obsidian/obsidian\346\217\222\344\273\266\345\274\200\345\217\221/obsidian\346\217\222\344\273\266\345\274\200\345\217\221\357\274\210\344\270\200\357\274\211\345\205\245\351\227\250/index.zh-cn.md"[m
[36m@@ -71,7 +71,6 @@[m [mimport { Notice, Plugin } from "obsidian";[m
 [m
 找到  `async onload()`  方法，添加以下代码[m
 ```js[m
[31m-await this.loadSettings();[m
 this.addRibbonIcon('dice', 'Greet',[m
 () => { new Notice('Hello, world!'); });[m
 ```[m
[1mdiff --git a/themes/DoIt b/themes/DoIt[m
[1m--- a/themes/DoIt[m
[1m+++ b/themes/DoIt[m
[36m@@ -1 +1 @@[m
[31m-Subproject commit 686aa5b011d34926865b73d900cce20b3b7b6a03[m
[32m+[m[32mSubproject commit 686aa5b011d34926865b73d900cce20b3b7b6a03-dirty[m
