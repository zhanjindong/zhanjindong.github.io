---
layout: post
title: "Java并发包源码学习之AQS框架（二）CLH lock queue和自旋锁"
description: "Java并发包源码学习之AQS框架（二）CLH lock queue和自旋锁"
categories: [articles]
tags: [Java,AQS]
alias: [/2015/03/11/]
utilities: fancybox,unveil,highlight
---

[上一篇文章][1]提到AQS是基于`CLH lock queue`，那么什么是CLH lock queue，说复杂很复杂说简单也简单，
所谓大道至简：

	CLH lock queue其实就是一个FIFO的队列，队列中的每个结点（线程）只要等待其前继释放锁就可以了。


`AbstractQueuedSynchronizer`是通过一个内部类`Node`来实现CLH lock queue的一个变种，但基本原理是类似的。

在介绍`Node`类之前，我们来介绍下`Spin Lock`,通常就是用`CLH lock queue`来实现自旋锁，所谓自旋锁简单来说就是线程通过循环来等待而不是睡眠。
Talk 再多不如 show code:

{% highlight Java %}

class ClhSpinLock {
	private final ThreadLocal<Node> prev;
	private final ThreadLocal<Node> node;
	private final AtomicReference<Node> tail = new AtomicReference<Node>(new Node());

	public ClhSpinLock() {
		this.node = new ThreadLocal<Node>() {
			protected Node initialValue() {
				return new Node();
			}
		};

		this.prev = new ThreadLocal<Node>() {
			protected Node initialValue() {
				return null;
			}
		};
	}

	public void lock() {
		final Node node = this.node.get();
		node.locked = true;
		// 一个CAS操作即可将当前线程对应的节点加入到队列中，
		// 并且同时获得了前继节点的引用，然后就是等待前继释放锁
		Node pred = this.tail.getAndSet(node);
		this.prev.set(pred);
		while (pred.locked) {// 进入自旋
		}
	}

	public void unlock() {
		final Node node = this.node.get();
		node.locked = false;
		this.node.set(this.prev.get());
	}

	private static class Node {
		private volatile boolean locked;
	}
}

{% endhighlight %}


{% highlight Java %}

上面的代码中线程巧妙的通过`ThreadLocal`保存了当前结点和前继结点的引用，自旋就是lock中的while循环。
总的来说这种实现的好处是保证所有等待线程的公平竞争，而且没有竞争同一个变量，因为每个线程只要等待自己的前继释放就好了。
而自旋的好处是线程不需要睡眠和唤醒，减小了系统调用的开销。

public static void main(String[] args) {
    final ClhSpinLock lock = new ClhSpinLock();
    lock.lock();

    for (int i = 0; i < 10; i++) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                lock.lock();
                System.out.println(Thread.currentThread().getId() + " acquired the lock!");
                lock.unlock();
            }
        }).start();
        Thread.sleep(100);
    }

    System.out.println("main thread unlock!");
    lock.unlock();
} 

{% endhighlight %}

上面代码的运行的结果应该跟[上一篇文章][1]中的完全一样。


`ClhSpinLock`的Node类实现很简单只有一个布尔值，`AbstractQueuedSynchronizer$Node`的实现稍微复杂点，大概是这样的：


     +------+  prev +-----+       +-----+
head |      | <---- |     | <---- |     |  tail
     +------+       +-----+       +-----+


- head：头指针
- tail：尾指针
- prev：指向前继的指针
- next：这个指针图中没有画出来，它跟prev相反，指向后继


关键不同就是next指针，这是因为AQS中线程不是一直在自旋的，而可能会反复的睡眠和唤醒，这就需要前继释放锁的时候通过next
指针找到其后继将其唤醒，也就是AQS的等待队列中后继是被前继唤醒的。AQS结合了自旋和睡眠/唤醒两种方法的优点。

其中线程的睡眠和唤醒就是用到我下一篇文章将要讲到的`LockSupport`。


最后提一点，上面的`ClhSpinLock`类中还有一个关键的点就是`lock`方法中注释的地方：

	一个CAS操作即可将当前线程对应的节点加入到队列中，并获取到其前继。


实际上可以说整个AQS框架都是建立在CAS的基础上的，这些原子操作是多线程竞争的核心地带，AQS中很多绕来绕去的代码都是为了
减少竞争。我会在后面`AbstractQueuedSynchronizer`源码分析中做详细介绍。


[1]: http://jindong.io/2015/03/10/java-concurrent-package-aqs-overview/


