---
layout: post
title: "又又见KeepAlive"
description: "又又见KeepAlive"
categories: [articles]
tags: [Nginx,KeepAlive]
alias: [/2016/12/13/]
utilities: fancybox,unveil,highlight
---


再次谈到KeepAlive，这次看下Nginx加Tomcat做反向代理这种典型场景下的KeepAlive配置与否的影响。以下图中的数据只能做个定性的参考，具体要根据实际业务测试。

<a class="post-image" href="/assets/images/posts/20161213-1.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-1.png" src="/assets/js/unveil/loader.gif" alt="20161213-1.png" />
</a>

<a class="post-image" href="/assets/images/posts/20161213-2.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-2.png" src="/assets/js/unveil/loader.gif" alt="20161213-2.png" />
</a>

<a class="post-image" href="/assets/images/posts/20161213-3.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-3.png" src="/assets/js/unveil/loader.gif" alt="20161213-3.png" />
</a>

<a class="post-image" href="/assets/images/posts/20161213-4.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-4.png" src="/assets/js/unveil/loader.gif" alt="20161213-4.png" />
</a>

<a class="post-image" href="/assets/images/posts/20161213-5.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-5.png" src="/assets/js/unveil/loader.gif" alt="20161213-5.png" />
</a>

<a class="post-image" href="/assets/images/posts/20161213-6.png">
<img itemprop="image" data-src="/assets/images/posts/20161213-6.png" src="/assets/js/unveil/loader.gif" alt="20161213-6.png" />
</a>

- 显然keepalive需要client和sever同时支持才生效；
- 未使用keepalive（无论是客户端还是服务端不支持），服务端会主动关闭TCP连接，存在大量的TIME_WAI；
- 是否使用keepalive比较复杂，并不是单纯的一个http头决定的；
- Nginx似乎跟upstream之间维持着一个长连接池，所以很少会看到TIME_WAIT，都处于ESTABLISHED状态。

Nginx有关KeepAlive的配置有两处：

一处是http节点下的keepalive_timeout，这个设置的是跟client(图中downstream)的连接超时时间；还有一处是upstream中配置的keepalive，注意这个单位是数量不是时间。


 [1]: http://blog.csdn.net/gzh0222/article/details/8523635

