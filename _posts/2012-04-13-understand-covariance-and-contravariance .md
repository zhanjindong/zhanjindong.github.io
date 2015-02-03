---
layout: post
title: "对协变和逆变的简单理解"
description: "对协变和逆变的简单理解"
categories: [articles]
tags: [C#]
alias: [/2012/04/13/]
utilities: fancybox,unveil,highlight
---

毕业快一年了，边工作边学习，虽说对.net不算精通，但也算入门了，但一直以来对协变和逆变这个概念不是太了解，上学时候mark了一些文章，今天回过头看感觉更糊涂了，真验证本人一句口头禅“知道的越多，知道的越少”。看到最后实在乱了，就干脆装糊涂好了，本人也算半个阴谋论者，在编程语言这方面当我实在没法吃透一个语法的时候，我就归咎于编译器这个幕后黑手。我们看下面两个类Derived派生自Base:
