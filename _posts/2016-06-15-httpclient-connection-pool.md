---
layout: post
title: "HttpClient连接池的连接保持、超时和失效机制"
description: "HttpClient连接池的连接保持、超时和失效机制"
categories: [articles]
tags: [HttpClient]
alias: [/2016/06/15/]
utilities: fancybox,unveil,highlight
---

HTTP是一种无连接的事务协议，底层使用的还是TCP，连接池复用的就是TCP连接，目的就是在一个TCP连接上进行多次的HTTP请求从而提高性能。每次HTTP请求结束的时候，HttpClient会判断连接是否可以保持，如果可以则交给连接管理器进行管理以备下次重用，否则直接关闭连接。这里涉及到三个问题：

## 1、如何判断连接是否可以保持？

要想保持连接，首先客户端需要告诉服务器希望保持长连接，这就是所谓的Keep-Alive模式（又称持久连接，连接重用），HTTP1.0中默认是关闭的，需要在HTTP头加入"Connection: Keep-Alive"，才能启用Keep-Alive；HTTP1.1中默认启用Keep-Alive，加入"Connection: close "，才关闭。

但客户端设置了Keep-Alive并不能保证连接就可以保持，这里情况比较复。要想在一个TCP上进行多次的HTTP会话，关键是如何判断一次HTTP会话结束了？非Keep-Alive模式下可以使用EOF（-1）来判断，但Keep-Alive时服务器不会自动断开连接，有两种最常见的方式。

### 使用Conent-Length

顾名思义，Conent-Length表示实体内容长度，客户端（服务器）可以根据这个值来判断数据是否接收完成。当请求的资源是静态的页面或图片，服务器很容易知道内容的大小，但如果遇到动态的内容，或者文件太大想多次发送怎么办？

### 使用Transfer-Encoding

当需要一边产生数据，一边发给客户端，服务器就需要使用 Transfer-Encoding: chunked 这样的方式来代替 Content-Length，Chunk编码将数据分成一块一块的发送。它由若干个Chunk串连而成，以一个标明长度为0 的chunk标示结束。每个Chunk分为头部和正文两部分，头部内容指定正文的字符总数（十六进制的数字 ）和数量单位（一般不写），正文部分就是指定长度的实际内容，两部分之间用回车换行(CRLF) 隔开。在最后一个长度为0的Chunk中的内容是称为footer的内容，是一些附加的Header信息。

对于如何判断消息实体的长度，实际情况还要复杂的多，可以参考这篇文章：https://zhanjindong.com/2015/05/08/http-keep-alive-header

总结下HttpClient如何判断连接是否保持：

1. 检查返回response报文头的Transfer-Encoding字段，若该字段值存在且不为chunked，则连接不保持，直接关闭。
2. 检查返回的response报文头的Content-Length字段，若该字段值为空或者格式不正确（多个长度，值不是整数），则连接不保持，直接关闭。
3. 检查返回的response报文头的Connection字段（若该字段不存在，则为Proxy-Connection字段）值：
	1. 如果这俩字段都不存在，则1.1版本默认为保持， 1.0版本默认为连接不保持，直接关闭。
	2. 如果字段存在，若字段值为close 则连接不保持，直接关闭；若字段值为keep-alive则连接标记为保持。

## 2、 保持多长时间？

保持时间计时开始时间为连接交换至连接池的时间。 保持时长计算规则为：获取response中 Keep-Alive字段中timeout值，若该存在，则保持时间为 timeout值*1000，单位毫秒。若不存在，则连接保持时间设置为-1，表示为无穷。

## 3、保持过程中如何保证连接没有失效？

很难保证。传统阻塞I/O模型，只有当I/O操做的时候，socket才能响应I/O事件。当TCP连接交给连接管理器后，它可能还处于“保持连接”的状态，但是无法监听socket状态和响应I/O事件。如果这时服务器将连接关闭的话，客户端是没法知道这个状态变化的，从而也无法采取适当的手段来关闭连接。

针对这种情况，HttpClient采取一个策略，通过一个后台的监控线程定时的去检查连接池中连接是否还“新鲜”，如果过期了，或者空闲了一定时间则就将其从连接池里删除掉。ClientConnectionManager提供了
closeExpiredConnections和closeIdleConnections两个方法。

参考文章

[HTTP协议头部与Keep-Alive模式详解][1]
[又见KeepAlive][2]

[1]: https://zhanjindong.com/2015/05/08/http-keep-alive-header

[2]: https://zhanjindong.com/2015/09/20/tcp-keep-alive
