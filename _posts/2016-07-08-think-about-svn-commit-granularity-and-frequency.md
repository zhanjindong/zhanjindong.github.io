---
layout: post
title: "关于SVN代码提交粒度和频率的思考"
description: "关于SVN代码提交粒度和频率的思考"
categories: [notes]
tags: [SVN]
alias: [/2016/07/08/]
utilities: fancybox, unveil, highlight
---

今天组内新来的一个同事问我代码提交频率的问题，他在上家公司是一个模块功能开发自测完成后再提交。而我这边采用的是最少一天提交一次，提倡粒度较小的提交，
而且是基于主干开发。采用这种方式是出于以下几点考虑：

1. 提交的粒度小，和别人冲突的可能性就小，避免代码冲突合并的痛苦。

2. 所有的开发都能看到最新的代码，在多模块协同开发的时候，可以及时的了解别人的进度，也是潜在的一个沟通方式。

3 .及时的发现问题，相对于每次提交上千行代码，几十个模块或方法，小粒度的提交倒逼开发及时的单元测试，有利于尽早的发现缺陷，而不是大海捞针般单步调试老长老长的代码。

4 .持续构建和持续发布，持续集成系统对提交的代码会自动进行静态扫描，定时的进行编译和构建，小粒度的提交能够及时的发现一些编译上或规范上的问题。

5 .代码安全，这种可能性虽然小 但也不能排除，尤其是核心模块的代码，辛辛苦苦好几天，硬盘损坏或电脑丢失就回到解放前。

6 .关于小粒度提交和主干开发，可能比较担心的就是上线问题，b需求还没开发完成，但a需求已经要求上线了，或者a模块上线后发现bug怎么办，关于这点，我的考虑是：

- 我们的开发和迭代比较快，基本是以周为单位，需求的粒度拆分的也会比较小和独立，所以两个需求的代码相互影响会比较小。

- 需求的可控性较好，我们的需求更多是内部的，压力没那么大，可以做较好的规划，说白了就是商量的余地比较大，因此冲突的可能性就小很多。

- 如果真出现冲突，就得需要将b需求的功能巧妙的隐藏起来，灵活的配置，灰度发布等。

总的来说我觉得这种方式适合比较敏捷的项目，对代码的结构和需求的管理要求比较高。另外不代表完全拒绝分支，遇到重大的功能修改时，
或者紧急修复线上问题的时候还是要拉分支的，只不过分支的战线尽量短。

