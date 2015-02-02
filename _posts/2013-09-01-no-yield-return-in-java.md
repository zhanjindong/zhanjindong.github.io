---
layout: post
title: "可惜Java中没有yield return"
description: "可惜Java中没有yield return"
categories: [articles]
tags: [Java]
alias: [/2013/09/01/]
utilities: fancybox, unveil
---

{% highlight %}
uid　　caller
123456　　12345678901
789101　　12345678901
……
{% endhighlight %}


现在要做的就是读取文件中的每一个用户然后给他推消息，具体的逻辑可能要复杂点，但今天关心的是如何遍历文件返回用户信息的问题。

之前用C#已经写过类似的代码，大致如下：

