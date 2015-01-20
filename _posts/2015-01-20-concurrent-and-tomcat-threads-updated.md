---
layout: post
title: "聊下并发和Tomcat线程数（错误更正）"
description: "聊下并发和Tomcat线程数（错误更正）"
categories: [articles]
tags: [Tomcat]
alias: [/2015/01/20/]
utilities: fancybox, unveil
---

之前在博客园写过一篇文章：[聊下并发和Tomcat线程数][1]。其中得出的结论是错误，特此更正下，如果误导了某些同学十分抱歉。原文也已同步更新了。

* Kramdown table of contents
{:toc .toc}

## 错误的结论
{: #wrong-conclusions}

那篇文章有问题的结论是：

	`Tomcat`不会主动对线程池进行收缩，除非确定没有任何请求的时候，Tomcat才会将线程池收缩到`minSpareThreads`设置的大小；
	`Tomcat6`之前的版本有一个`maxSpareThreads`参数，但是在7中已经移除了，所以只要前面哪怕只有一个请求，Tomcat也不会释放多于空闲的线程。


## 线程数、TPS、maxIdleTime之间的关系
{: #relationship-between-thread-count-tps-maxIdleTime}

其实**Tomcat会停止长时间闲置的线程。**Tomcat还有一个参数叫[`maxIdleTime`][2]：

> (int) The number of milliseconds before an idle thread shutsdown, unless the number of active threads are less or equal to minSpareThreads. Default value is 60000(1 minute)

其实从这个参数解释也能看出来`Tomcat`会停止闲置了超过一定时间的线程的，这个时间就是`maxIdleTime`。但我之前的测试中确实没有发现线程释放的现象，这是为什么呢？我发现除了这个参数线程池线程是否释放？释放多少？还跟当前`Tomcat`每秒处理的请求数（从`Jmeter`或`LoadRunner`来看可以理解为`TPS`）有关系。通过下表可以清晰的看出来`线程数`，`TP`S和`maxIdleTime`之间的关系：

{% datatable %}
<tr>
	<th>TPS</th>
	<th>maxIdleTime(ms)</th>
	<th>Thread Count</th>
</tr>
<tr>
	<th>10</th>
	<th>60,000(ms)</th>
	<th>600</th>
</tr>
<tr>
	<th>5</th>
	<th>60,000(ms)</th>
	<th>300</th>
</tr>
<tr>
	<th>1</th>
	<th>60,000(ms)</th>
	<th>60</th>
</tr>
{% enddatatable %}

依次类推，上表中Thread Count这一列是一个大约数，上下相差几个，但基本符合这样一个规则：

	Thread Count = (TPS * maxIdleTime)/1000

当然这个`Thread Count`不会小于`minSpareThreads`，这个跟之前的结论还是一样的。我现在大胆猜测下（回头看源码验证下，或者哪位同学知道告诉我下，谢谢）：

> Tomcat线程池每次从队列头部取线程去处理请求，请求完结束后再放到队列尾部，也就是说前后两次请求处理不会用同一个线程。某个线程闲置超过maxIdleTime就释放掉。

<a class="post-image" href="/assets/images/posts/201812241101914.png">
<img itemprop="image" data-src="/assets/images/posts/201812241101914.png" src="/assets/js/unveil/loader.gif" alt="201812241101914.png" />
</a>

假设首先线程池在高峰时期暴涨到1000，高峰过后`Tomcat`处理一次请求需要1s（从Jmeter看TPS大约就为1），那么在`maxIdleTime`默认的60s内会用到线程池中60个线程，那么最后理论上线程池会收缩到60（假设minSpareThreads大于60）。**另外：这个跟用不用Keep-Alive没关系（之前测试结论是因为用了Keep-Alive导致程序性能下降，TPS降低了很多导致的）**

这就是为什么我之前的测试中、还有我们生产环境中线程数只增不减的原因，因为就算峰值过后我们的业务每秒请求次数仍然有100多，100*60=6000，也就是3000个线程每个线程在被回收之前肯定会被重用。

## 线程池为什么会满
{: #why-thread-pool-surge}

那么现在有另外一个问题，那么正常情况下为什么每秒100次的请求不会导致线程数暴增呢？也就是说线程暴增到`3000`的瓶颈到底在哪？这个我上面的结论其实也不是很准确。

	真正决定`Tomcat`最大可能达到的线程数是`maxConnections`这个参数和并发数，当并发数超过这个参数则请求会排队，这时响应的快慢就看你的程序性能了。

这里没说清楚的是并发的概念，不管什么并发肯定是有一个时间单位的（一般是1s），准确的来讲应该是当时Tomcat处理一个请求的时间内并发数，比如当时Tomcat处理某一个请求花费了1s，那么如果这1s过来的请求数达到了3000，那么Tomcat的线程数就会为3000，maxConnections只是Tomcat做的一个限制。

欢迎斧正！

## 补充
{: #jmeter-frequence}


使用`Jmeter`可以很容易的控制请求的频率。

<a class="post-image" href="/assets/images/posts/201844220947370.png">
<img itemprop="image" data-src="/assets/images/posts/201844220947370.png" src="/assets/js/unveil/loader.gif" alt="201844220947370.png" />
</a>

<a class="post-image" href="/assets/images/posts/201844332501077.png">
<img itemprop="image" data-src="/assets/images/posts/201844332501077.png" src="/assets/js/unveil/loader.gif" alt="201844332501077.png" />
</a>





 [1]: http://www.cnblogs.com/zhanjindong/p/concurrent-and-tomcat-threads.html
 [2]: http://tomcat.apache.org/tomcat-7.0-doc/config/executor.html

