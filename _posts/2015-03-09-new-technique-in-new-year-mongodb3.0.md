---
layout: post
title: "新年新技术:MongoDB 3.0"
description: "新年新技术:MongoDB 3.0"
categories: [notes]
tags: [MongoDB]
alias: [/2015/03/09/]
utilities: fancybox,unveil,highlight
---

前一篇介绍了HTTP/2，这一篇简单介绍下3月3号发布的MongoDB 3.0。


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


## 官方文档
{: #official-docs}

[MongoDB 3.0][9]


## 【补充】MongoDB 3.2

- WiredTiger作为默认的存储引擎。

- 副本集的选举性能能提升，新的协议（protocolVersion:1）支持electionTimeoutMillis选举超时配置。

- 分片集群性能提升，config server可以做副本集部署解决单点问题（只能使用WiredTiger ）。

- readConcern：副本集，分片副本集结构，对于WiredTiger引擎可以设置为majority，避免读脏数据的问题。

- 部分索引：建立索引的时候可以跟上一个表达式，只对满足条件的文档建立索引，这样可以减小索引建立和维护的成本，降低内存使用。是稀疏索引功能的超集，但性能会更好。

- 文档验证，在更新插入操作的时候对文档内容进行验证，比如phone字段是否是一个合法的手机号码。

- 聚合框架的性能提升。

更多内容参看 [MongoDB 3.2][11] 

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
[11]: https://docs.mongodb.org/manual/release-notes/3.2/