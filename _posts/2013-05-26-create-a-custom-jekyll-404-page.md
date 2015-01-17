---
layout: post
title: "创建自定义的 Jekyll 404 页面"
description: "如何给保存在 GitHub Pages 上的网站创建自定义的404页面，并使用 HTML meta 标签使之能在一段时间后自动跳转回主页。"
categories: [articles, popular]
tags: [jekyll, github]
alias: [/2013/05/26/]
last_updated: March 18, 2014
utilities: highlight
---
> 若想查看原文，请点击[本链接](http://yizeng.me/2013/05/26/create-a-custom-jekyll-404-page/)。

本文示例了如何给储存在 [GitHub Page](http://pages.github.com/) 服务器上的 Jekyll 网站创建自定义的 Jekyll 404 页面，对于使用其他服务器的 Jekyll 网站情况可能有所不同。同时还需要注意的是，自定义的 404 页面仅对使用了自己域名的网站有效。查看更详细官方的文档，请点击 GitHub Pages 的官方文档 [Custom 404 Pages - GitHub Help](https://help.github.com/articles/custom-404-pages)。

* Kramdown table of contents
{:toc .toc}

## 创建 404.html 文件
{: #create-404-file}

在 Jekyll 网站的根目录下创建 `404.html`，<del>此文件必须为 HTML 格式</del>{% footnote 1 %}。

## 添加 YAML Front Matter
{: #add-front-matter}

由于本文的目标是创建一个和其他所有页面主题一致的自定义 404 页面，而非重写一个单独的 404.html，所以首先添加[YAML Front Matter](http://jekyllrb.com/docs/frontmatter/)至 404.html 的头部并设置 layout 为 "page"。

	---
	layout: page
	title: 404
	---

## 添加 404 内容
{: #add-404-content}

在 [YAML Front Matter](http://jekyllrb.com/docs/frontmatter/) 部分后添加真正的404内容。

	---
	layout: page
	title: 404
	---
	<p>对不起，无法找到该页。 =(</p>

## 自动跳转 404 页面
{: #redirect-page}

为了让 404 页面能自动跳转，迄今为止所找到的最简单的方法是通过 HTML meta 标签，`meta http-equiv="refresh"`{% footnote 2 %}。

1. 在 Jekyll 的 default.html 文件里 (例如： 本网站的在 /_includes/themes/THEME_NAME/default.html), 在 `<head>` 标签内添加一个 `<meta>` 标签。 ([W3schools 示例](http://www.w3schools.com/tags/att_meta_http_equiv.asp))

2. 给 meta 标签添加一个 `http-equiv` 属性并设置为 "refresh", i.e `<meta http-equiv="refresh">`.

3. 再给 meta 标签添加一个 `content` 属性并设置为 `content="5; url=/"`。
	- `5` 代表着在自动跳转前所等待的秒数。 设置为 `0` 表示不做任何等待并立即跳转。
	- `url=/` 设置了跳转的 URL， 可以被设置成任何链接，如 `url=http://yizeng.me`。

4. 使用 [Liquid's if-else](http://wiki.shopify.com/Liquid#If_.2F_Else_.2F_Unless) 语句来确保自动跳转只发生于 `404.html`。

<script src="https://gist.github.com/yizeng/a4f26459bc8795476ed4.js"></script>

**以下为一个完整的 `default.html` 示例:**

<script src="https://gist.github.com/yizeng/5428d29c3d5af224475b.js"></script>

## 测试 404 页面
{: #test-404-page}

1. 在本地使用命令 `jekyll serve` 来 build Jekyll 服务器，然后前往 `localhost:4000/404.html`, 看看自定义的 404 页面是否正常工作。

2. 提交至 GitHub 看看是否 404 能正常工作。

3. 前往网站上的一个不存在的网址，如 http://yizeng.me/go_404，看页面是否能正常显示，是否能自动跳转至指定的页面。

{% footnotes %}
<p id="footnote-1">
[1]: 官方文档内已经删除此句。
{% reverse_footnote 1 %}
</p>
<p id="footnote-2">
[2]: <a href="http://www.w3schools.com/tags/att_meta_http_equiv.asp">"HTML &lt;meta&gt; http-equiv Attribute" 实例</a> by W3schools.
{% reverse_footnote 2 %}
</p>
{% endfootnotes %}
