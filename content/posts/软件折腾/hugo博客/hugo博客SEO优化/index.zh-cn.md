---
date: 2023-11-10T23:31:49.503Z
lastmod: 2023-11-10T23:31:49.503Z
categories:
  - 软件折腾
  - hugo博客
title: hugo博客SEO优化
draft: "false"
tags:
  - hugo
series:
---
今天在提交页面索引给bing的时候，给出了一些优化意见：
## 不能有多个h1标签
```text {linenos=false}
More than one h1 tag

- 4 instances found

How to fix?

What is the issue about?These pages have more than one <h1> tag. Multiple <h1> header tags might confuse search engine bots and website's users. It is recommended to use only one <h1> tag per page.

How to fix?
Remove redundant <h1> tags from the page source, so that only one <h1> tag exists.
```
之前还郁闷为什么hugo的目录为什么这么奇怪，当我把所有的h1都换成h2，发现hugo文章的目录也正常显示了。


## meta标签内容不能过长 
```text {linenos=false}
Meta Description too long or too short

- 1 instance found

How to fix?

What is the issue about?

Search engine crawlers only show the first 150-160 characters of the description in the search results page, so if a description is too long, searchers may not see all of the text. If a description is too short, the search engines may add text found elsewhere on the page. Note that search engines may show a different description from the one you have authored if they feel it may be more relevant to a user's search.

How to fix?
Change the description in the <meta description> tag in the page source to be between 25 and 160 characters in length.
```

通过元素审查发现meta标签如下
```html
	<meta property="og:description" content="1 准备Windows11安装包和虚拟机安装包进入官网界面，找到下载 Windows 11 磁盘映像 (ISO)，选择下载项为Windows11(multi-edi">
```
以及
```html
<meta name="twitter:description" content="1 准备Windows11安装包和虚拟机安装包进入官网界面，找到下载 Windows 11 磁盘映像 (ISO)，选择下载项为Windows11(multi-edi">
```

可以看到又twitter:description和og:description这连个属性的标签。我记得我明明关闭了twitter的分享，为什么仍然出现了twitter以及另一个不认识的标签呢？

于是再次确认社交配置的确关闭了twitter
![](Pasted%20image%2020231113001137.png)


通过 webstrom打开站点根目录，搜索description，没有找到具体文章的description配置。有的也只是配置站点的description，而非meta标签上的twitter。
![](Pasted%20image%2020231113000549.png)


meta必然是在头部区域，于是在layout里面查找header.html仍旧未找到twitter相关配置，但是在主题的`layout>partials>head`下找到一个`meta.html`，其中包括了两个模板，twitter_cards和opengraph，这不就是og的缩写吗？
```html
{{- $params := .Scratch.Get "params" -}}  
  
<meta name="Description" content="{{ $params.description | default .Site.Params.description }}">  
  
{{- template "_internal/opengraph.html" . -}}  
{{- template "_internal/twitter_cards.html" . -}}  
  
<meta name="application-name" content="{{ .Site.Params.app.title | default .Site.Title }}">  
<meta name="apple-mobile-web-app-title" content="{{ .Site.Params.app.title | default .Site.Title }}">  
  
<meta name="theme-color" content="#f8f8f8">  
  
{{- with .Site.Params.app.tileColor -}}  
    <meta name="msapplication-TileColor" content="{{ . }}">  
{{- end -}}  
  
{{- with .Site.Params.social.Twitter -}}  
<meta name="twitter:creator" content="@{{ . }}" />  
{{- end -}}
```
于是我把这两个模板注释掉，果然包含`twitter:description`和`og:description`的meta标签就没有出现在网页上。



这两个到底是啥玩意？通过搜索关键字`hugo twitter_cards`找到hugo官网关于内部模板的使用方法，往下拉找到 twitter_card https://gohugo.io/templates/internal/#twitter-cards 的使用方法，以及源代码链接 [twitter_card.html](https://github.com/gohugoio/hugo/blob/master/tpl/tplimpl/embedded/templates/twitter_cards.html), 在第20行找到了description

```html {linenostart=20}
<meta name="twitter:title" content="{{ .Title }}"/>
<meta name="twitter:description" content="{{ with .Description }}{{ . }}{{ else }}{{if .IsPage}}{{ .Summary }}{{ else }}{{ with .Site.Params.description }}{{ . }}{{ end }}{{ end }}{{ end -}}"/>

```
看起来优先级 文章`front-matter`的`description` > 页面的`.Summary`，站点的`.Summary`
一般来说我都不给页面写description，因为主要信息都包含在标题中，懒得在写一次。于是可以确定他是读取`.Summary`变量生成的长文本。那么有没有办法控制summary变量的长度呢？

于是继续搜索关键字`hugo .Summary`
https://gohugo.io/content-management/summaries/
对这个变量的描述如下
> With the use of the `.Summary` [page variable](https://gohugo.io/variables/page/), Hugo generates summaries of content to use as a short version in summary views.

当使用.Summary变量的时候，会自动生成作为页面视图的摘要。


> By default, Hugo automatically takes the first 70 words of your content as its summary and stores it into the `.Summary` page variable for use in your templates. You may customize the summary length by setting `summaryLength` in your [site configuration](https://gohugo.io/getting-started/configuration/).

hugo会自动取文本的前70个字符作为摘要，你可以通过`summaryLength` 变量来调整摘要长度。这不就是我们想要调整的变量吗？那么这个变量在哪里调整呢，原文中旁边刚好有[site configuration链接]([Configure Hugo | Hugo (gohugo.io)](https://gohugo.io/getting-started/configuration/))，点进去按下`Ctrl + f`搜索 `summaryLength`，果然搜索到了

- **Default value:** 70
- The length of text in words to show in a [`.Summary`](https://gohugo.io/content-management/summaries/#automatic-summary-splitting).





## 总结：
1. 把h1换成h2
2. 修改参数