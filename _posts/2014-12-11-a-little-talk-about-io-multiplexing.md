---
layout: post
title: "简单聊下IO复用"
description: "简单聊下IO复用"
categories: [articles]
tags: [IO]
alias: [/2014/11/03/]
utilities: highlight
---

**没图，不分析API**

Java中IO API的发展：

Socket -> SocketChannel -> AsynchronousSocketChannel

ServerSocket -> ServerSocketChannel -> AsynchronousServerSocketChannel

同步/阻塞 -> 同步/非阻塞(多路复用) -> 异步

想简单聊下多路复用。多路复用需要配合Reactor模式，前者解决技术上的问题，后者解决软件工程的问题。

技术上的问题，是将IO操作中等待和非等待的部分分开处理。我们都知道IO操作分为两个部分：

1、等待数据就绪

2、处理数据

众所周知的几种IO模型（阻塞、非阻塞、多路复用、信号驱动、异步）就是区别于这两个阶段，当需要处理很多连接的时候（高并发的情况），容易想到的是使用多线程技术，比如最简单的`One-connection-Per-thread`模式，但是因为等待数据不可避免，造成的结果是线程不停的休眠-唤醒的切换，导致CPU不堪重负。

IO复用的目的：将这两个阶段分开处理，让一个线程（而且是内核级别的线程）来处理所有的等待，一旦有相应的IO事件发生就通知继续完成IO操作，虽然仍然有阻塞和等待，但是等待总是发生在一个线程，这时使用多线程可以保证其他线程一旦唤醒就是处理数据，当然这需要非阻塞IO API的支持（比如非阻塞套接字）。Linux2.6之前的`select`,`poll`以及之后的`epoll`都是IO复用技术的实现。select和poll基本一致，epoll是对它们的改进版本。但总的来说它们都还不是真正的异步IO，因为它们在IO读写的时候仍然是阻塞的、同步的（完成一件事后才能做另外一件事）。异步IO是指“处理数据”这一阶段也是非阻塞的。Windows上的IOCP（完成端口）才是真正的AIO，理论上它比Linux的epoll更先进。

至于`select`、`poll`和`epoll`的区别，推荐[这篇文章][1]。简单来说：`select`,`poll`无脑的轮询，忽略了高并发下，轮询本身成了瓶颈，而epoll使用回调实现了轮询真正需要处理的连接。

Reactor模式是为了我们更简单的使用IO复用技术。它是一种并发IO模式，其他的模式还有多进程，多线程等。`Reactor`本身也有很多变种，比如`thread per request``,worker thread`,`thread pool`，`multiple reactors`...网上这方面的资料很多。虽然网上关于reactor和多线程模孰优孰劣还有争论(`Reactor`最明显的一个缺点是无法充分利用多核的优势)，但是大部分高并发的框架或组建都是基于reactor的，比如`MINA`,`Netty`，再比如`Redis`,`Nginx`(有多个工作进程来充分利用多核的优势)。关于Java中的IO复用可以看Doug Lea大神的[Scalable IO in Java][3]。

至于JDK1.7中出现的`Asynchronous I/O`，只要是运行Linux上肯定无外乎`epoll`，那是不是可以说本质上仍然不是真正的异步IO呢？个人觉得异步这个概念是有粒度的，不可能做到完全的异步。JDK1.7中的AIO从编程的角度对程序员来说确是异步的，我们不用像在多路复用中那样自己去`select`了，我们需要做的就是在`completion handlers`中处理业务逻辑。

另外提一点：操作系统底层的IO操作都是异步的——IO中断，只不过同步更符合正常人的思维，更易于理解。

 

最后关于异步IO还想补充一点，虽然异步IO的第二阶段也是非阻塞的，但是仍然有优化空间。就是在数据从内核copy到用户空间这个过程，Netty就使用了[Zero-Copy][2]技术来优化这个步骤，另外还有`MMAP`。

 

欢迎斧正！

 [1]: http://www.cnblogs.com/Anker/p/3265058.html
 [2]: http://my.oschina.net/plucury/blog/192577
 [3]: http://gee.cs.oswego.edu/dl/cpjslides/nio.pdf