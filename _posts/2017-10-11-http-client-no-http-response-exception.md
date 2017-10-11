---
layout: post
title: "HttpClient NoHttpResponseException问题排查"
description: "HttpClient NoHttpResponseException问题排查"
categories: [articles]
tags: [Nginx,KeepAlive]
alias: [/2017/10/11/]
utilities: httpclient,keepalive,tcp
---


生成环境有服务A通过HttpClient访问服务B，服务B位于Nginx反向代理后面。

最近A端一直有出现 NoHttpResponseException 的问题。


<a class="post-image" href="/assets/images/posts/20171011-2.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-2.png" src="/assets/js/unveil/loader.gif" alt="20171011-2.png" />
</a>

服务A HttpClient 使用了 PoolingHttpClientConnectionManager，相对BasicHttpClientConnectionManager来说，PoolingHttpClientConnectionManager是个更复杂的类，它管理着连接池，可以同时为很多线程提供http连接请求。Connections are pooled on a per route basis.当请求一个新的连接时，如果连接池有有可用的持久连接，连接管理器就会使用其中的一个，而不是再创建一个新的连接。
HttpClient连接池和服务端（Nginx）建立的是持久连接，而且Nginx也开启了持久连接的功能，keepalive_timeout设置为15s，表示连接空闲15s后Nginx将主动关闭连接。

<a class="post-image" href="/assets/images/posts/20171011-1.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-1.png" src="/assets/js/unveil/loader.gif" alt="20171011-1.png" />
</a>

之前有关keepalive总结的文章中提过：

> 经典阻塞I/O模型的一个主要缺点就是只有当阻塞I/O时，socket才能对I/O事件做出反应。当连接被管理器收回后，这个连接仍然存活，但是却无法监控socket的状态，也无法对I/O事件做出反馈。如果连接被服务器端关闭了，客户端监测不到连接的状态变化（也就无法根据连接状态的变化，关闭本地的socket）。HttpClient为了缓解这一问题造成的影响，会在使用某个连接前，监测这个连接是否已经过时，如果服务器端关闭了连接，那么连接就会失效。这种过时检查并不是100%有效，并且会给每个请求增加10到30毫秒额外开销。唯一一个可行的，且does not involve a one thread per socket model for idle connections的解决办法，是建立一个监控线程，来专门回收由于长时间不活动而被判定为失效的连接。这个监控线程可以周期性的调用ClientConnectionManager类的closeExpiredConnections()方法来关闭过期的连接，回收连接池中被关闭的连接。它也可以选择性的调用ClientConnectionManager类的closeIdleConnections()方法来关闭一段时间内不活动的连接。

线上的代码实际已经使用了监控线程来清理空闲的连接，但空闲超时时间设置的30s。

结合上面信息以及抓包分析，问题原因很可能是：Nginx在连接空闲15s后主动发送关闭连接，经过抓包测试发现HttpClient长连接机制即使收到了服务端的FIN仍然不会主动关闭连接，只有当显示的调用连接池的
closeIdleConnections方法时才会关闭，而这个超时设置的是30s，因此就会存在客户端从连接池中拿到的是服务端已经关闭的连接的情况。

解决办法大概有几种：

- 客户端使用短连接，比如换成UrlConnection；
- 将HttpClient连接保活时间调的小于15s或者将nginx的keepalive_timeout调的大于30s；
- 不用PoolingHttpClientConnectionManager。


下面是排查中的一些抓包：

36.7.172.115服务的IP，10.1.201.239是我本地IP，可以看到请求空闲15s后服务端主动关闭连接，但是客户端一直没有关闭。


<a class="post-image" href="/assets/images/posts/20171011-3.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-3.png" src="/assets/js/unveil/loader.gif" alt="20171011-3.png" />
</a>

下面是开启了HttpClient的清理空闲30s连接功能，因为代码里后台清理线程启动时候还等了5s，所以是35s后HttpClient发起了FIN，但这时候服务端已经主动关闭了。

<a class="post-image" href="/assets/images/posts/20171011-4.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-4.png" src="/assets/js/unveil/loader.gif" alt="20171011-4.png" />
</a>

<a class="post-image" href="/assets/images/posts/20171011-5.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-5.png" src="/assets/js/unveil/loader.gif" alt="20171011-5.png" />
</a>

把HttpClient的时间设置为5s后可以看到这次是客户端先关闭了连接。

<a class="post-image" href="/assets/images/posts/20171011-6.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-6.png" src="/assets/js/unveil/loader.gif" alt="20171011-6.png" />
</a>

但是上面的情况根据实际的模拟测试：将httpclient连接池设置为1，模拟刚好在服务端关闭连接，httpclient还没清理连接中间再起发起请求，发现并不会出现问题，抓包可以看到HttpClient在发起请求前会断开之前的连接（55638）重新和服务端建立连接（55693）完成请求。

<a class="post-image" href="/assets/images/posts/20171011-7.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-7.png" src="/assets/js/unveil/loader.gif" alt="20171011-7.png" />
</a>

网上查到的资料 HttpCient 正常情况都是可以处理这种Half-Open连接的，只有在特别的情况下会出现问题。按照HttpClient代码注释意思是：拿到连接使用的瞬间刚好被服务端关闭了。

> Most likely persistent connections that are kept alive by the connection manager become stale. That is, the target server shuts down the connection on its end without HttpClient being able to react to that event, while the connection is being idle, thus rendering the connection half-closed or 'stale'. Usually this is not a problem. HttpClient employs several techniques to verify connection validity upon its lease from the pool. Even if the stale connection check is disabled and a stale connection is used to transmit a request message the request execution usually fails in the write operation with SocketException and gets automatically retried. However under some circumstances the write operation can terminate without an exception and the subsequent read operation returns -1 (end of stream). In this case HttpClient has no other choice but to assume the request succeeded but the server failed to respond most likely due to an unexpected error on the server side. The simplest way to remedy the situation is to evict expired connections and connections that have been idle longer than, say, 1 minute from the pool after a period of inactivity. For details please see 

<a class="post-image" href="/assets/images/posts/20171011-8.png">
<img itemprop="image" data-src="/assets/images/posts/20171011-8.png" src="/assets/js/unveil/loader.gif" alt="20171011-8.png" />
</a>

另外经过测试将HttpClient的连接池调小可以缓解这个问题，说明连接池设置需要跟实际业务的压力相匹配，太大容易造成连接空闲可能也是导致上述问题的原因。


参考文章：

[1]: http://www.yeetrack.com/?p=782
[2]: http://blog.csdn.net/kobejayandy/article/details/44284057
[3]: https://stackoverflow.com/questions/10558791/apache-httpclient-interim-error-nohttpresponseexception


