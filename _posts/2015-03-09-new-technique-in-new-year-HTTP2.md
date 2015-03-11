---
layout: post
title: "新年新技术:HTTP/2"
description: "新年新技术:HTTP/2"
categories: [notes]
tags: [Technique]
alias: [/2015/03/09/]
utilities: fancybox,unveil,highlight
---

新的一年，项目也要带着发展的眼光往前走，得跟上潮流，当然前提是自己真的用的上。
用的上用不上都得先简单了解下。

2月下旬Google发布了首个基于HTTP/2的RPC框架GRPC，它是基于HTTP/2的，所以先了解下它，后续等深入研究了再回头说说GRPC。


* Kramdown table of contents
{:toc .toc}


## What’s new in HTTP/2?
{: #new-in-http2}

### is binary, instead of textual
{: #based-binary}

HTTP/2基于二进制而不是文本，二进制协议解析起来效率会更高，而且不那么容易出错，此外原来基于HTTP/1.x协议程序可以用[多种方式解析消息体][6]，
但是HTTP/2只有一种方式，这点对实现者来说负担更轻点。

### is fully multiplexed, instead of ordered and blocking
{: #multiplexed}

HTTP/1.x实际上是一个请求一个连接，因此浏览器为了提高页面的加载速度都会开多个连接，但是这也是有限制的（[不同的浏览器不一样][7]）。
太多的连接带来的是互联网上更多的拥塞和占用了更多的资源，这本身是低效而且是不公平的（对其他协议来说）。

HTTP/2的一个重要目的是让浏览器和服务器之间只建立一个连接，用一个连接实现了并行的请求处理，这就是multiplexing。

> 因为基于二进制所以telnet无法使用HTTP/2。

### can therefore use one connection for parallelism
{: #one-connection-for-parallelism}

上面已经提到了，HTTP/2只允许浏览器和服务器之间建立一个连接，用一个连接实现并行，减少TCP连接数。

### uses header compression to reduce overhead
{: #header-compression}

现在网页加载是资源密集型的，一个页面通常有很多资源要加载，每次请求的头部数据不可忽视（尤其是Cookies），
加上TCP的[Slow Start][8]机制（一种拥塞控制机制）会导致往返次数加大。压缩可以有效的减少包分组的数量，从而减少延迟，尤其是在移动端上。

因为GZIP压缩有安全性隐患，所以HTTP/2自己实现了一套压缩算法——HPACK。

### allows servers to “push” responses proactively into client caches
{: #push}

目前服务器需要浏览器解析页面后再发送新请求来获取js,css,图片等资源。HTTP/2为了优化这个开销，可以提前将这些资源“推送”到客户端的缓存中。

### 目前HTTP/2的使用情况？
{: #http2-implementations}

Github上专门有一个[Wiki][11]页跟踪了有哪些HTTP/2的实现。我们比较关心的是Google发布的GRPC。

<a class="post-image" href="/assets/images/posts/http2-impl.png">
<img itemprop="image" data-src="/assets/images/posts/http2-impl.png" src="/assets/js/unveil/loader.gif" alt="http2-impl.png" />
</a>

## 官方文档
{: #official-docs}

上述内容都是官方文档的内容，深入了解最好方式还是看官方的文档。

[HTTP/2][10]





[1]: http://docs.mongodb.org/manual/administration/production-notes/#prod-notes-wired-tiger-concurrency
[2]: http://docs.mongodb.org/manual/core/storage/#power-of-2-allocation
[3]: http://docs.mongodb.org/manual/reference/glossary/#term-padding-factor
[4]: http://docs.mongodb.org/manual/reference/explain-results/
[5]: http://www.grpc.io/
[6]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.4
[7]: http://stackoverflow.com/questions/985431/max-parallel-http-connections-in-a-browser
[8]: http://en.wikipedia.org/wiki/Slow-start
[9]: http://docs.mongodb.org/manual/release-notes/3.0/
[10]: https://http2.github.io
[11]: https://github.com/http2/http2-spec/wiki/Implementations