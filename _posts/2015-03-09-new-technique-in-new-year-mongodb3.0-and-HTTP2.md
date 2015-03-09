---
layout: post
title: "新年新技术:MongoDB 3.0和HTTP/2"
description: "新年新技术:MongoDB 3.0和HTTP/2"
categories: [notes]
tags: [Technique]
alias: [/2015/03/09/]
utilities: fancybox,unveil,highlight
---

新的一年，项目也要带着发展的眼光往前走，得跟上潮流，当然前提是自己真的用的上。
用的上用不上都得先简单了解下。

2月下旬Google发布了首个基于HTTP/2的RPC框架GRPC，3月3号MongoDB 3.0发布。今天就简单介绍下MongoDB 3.0和HTTP/2。


* Kramdown table of contents
{:toc .toc}

## What’s new in MongoDB 3.0?
{: #new-in-mongodb3.0}

### 新的存储引擎WiredTiger
{: #WiredTiger}

MongoDB 3.0的存储引擎是插件式的，默认为新增的[WiredTiger][1]。WiredTiger相比原来的MMAPv1引擎的优点：

- 文档级别的锁

这个改进真是盼望已久啊，一直以来MongoDB的锁粒度都被人诟病，根据我们实际的经验MongoDB在高并发的读写混合场景下性能很差。


- 更高的压缩比

新的MongoDB使用了前缀压缩 （Prefix Compression），大大提高了索引数据的压缩比。从我们运维同事的简单的测试结果来看很客观：

<a class="post-image" href="/assets/images/posts/mongodb3.0-compress.png">
<img itemprop="image" data-src="/assets/images/posts/mongodb3.0-compress.png" src="/assets/js/unveil/loader.gif" alt="mongodb3.0-compress.png" />
</a>

- 写性能提高

官方的说是提高了7-10倍，从我们简单的测试结果看虽然没有那么夸张但确实有不小提升：

<a class="post-image" href="/assets/images/posts/mongodb3.0-write.png">
<img itemprop="image" data-src="/assets/images/posts/mongodb3.0-write.png" src="/assets/js/unveil/loader.gif" alt="mongodb3.0-write.png" />
</a>

我们2.x版本测试结果大概2w不到。


> 注意：WiredTiger只能用于64位的机器。


### MMAPv1引擎的改进
{: #MMAPv1-improve}

虽然新增了WiredTiger，但是对原来的MMAPv1引擎也做了改进。


- 新的记录分配策略

MongoDB 3.0使用[power of 2 allocation][2]代替原来的动态记录分配，且弃用了[paddingFactor][3]。

原来的分配策略在文档变大超过初始分配的大小的时候，MongoDB要分配一个新的记录，并要移动数据和更新索引，导致存储碎片。
`power of 2 allocation`的策略是分配的记录的大小都是2的次方（32, 64, 128, 256, 512 ... 2MB），每个记录包括文档本身和额外的空间——padding，这个机制减少了文档增长的时候记录重新分配和数据移动的操作。

显然新的策略在处理大文档和文档增长频繁的场景下效率更高，但如果只有插入操纵和所谓的in-place更新操作（不会增长文档大小）那么使用这种策略会很浪费空间，因此MongoDB 3.0允许你关闭这种策略。


- 集合级别的锁

虽然没有WiredTiger的锁粒度小，但是相比之前MMAPv1还是挺重要的一个改进。


### Explain
{: #Explain}

新增[Explain][4]，类似MySQL的查询计划，做性能调优的时候很有用处。


### 查询API的改进
{: #query-API-improve}

- aggregate()新增$dateToString 操作符，支持将日志转换为指定的格式

- 查询新增 $eq 操作符支持相等判断


### 索引
{: #index-improve}

- 后台创建索引时不会被dropDatabase，drop和dropIndexes操作中断。


### 工具
{: #tools}

主要是mongodump和mongorestore功能的改进。


### 新的Java驱动
{: #new-java-driver}

简单的看了下源码，原来的API仍然兼容，但重写了很多主要类（MongoCollection，MongoDatabase），新的MongoIterable接口风格很像Java8的Stream，而且都是泛型的。
提供了异步的MongoClient，新的编码框架，提高了性能。


## What’s new in HTTP/2?
{: #new-in-http2}

其实我们关心的是Google的[GRPC][5]，但它是基于HTTP/2的，所以先了解下它，后续等深入研究了再回头说说GRPC。

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

Github上专门有一个Wiki页跟踪了有哪些HTTP/2的实现。我们比较关心的是Google发布的GRPC。

<a class="post-image" href="/assets/images/posts/http2-impl.png">
<img itemprop="image" data-src="/assets/images/posts/http2-impl.png" src="/assets/js/unveil/loader.gif" alt="http2-impl.png" />
</a>


上述内容都是官方文档的内容，深入了解最好方式还是看官方的文档。

## 官方文档
{: #official-docs}

[MongoDB 3.0][9]

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