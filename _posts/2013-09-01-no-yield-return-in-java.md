---
layout: post
title: "可惜Java中没有yield return"
description: "可惜Java中没有yield return"
categories: [articles]
tags: [Java]
alias: [/2013/09/01/]
utilities: fancybox, unveil, highlight
---

项目中一个消息推送需求，推送的用户数几百万，用户清单很简单就是一个txt文件，是由hadoop计算出来的。格式大概如下：

{% highlight %}
uid　　caller
123456　　12345678901
789101　　12345678901
……
{% endhighlight %}


