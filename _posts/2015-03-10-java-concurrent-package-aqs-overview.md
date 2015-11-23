---
layout: post
title: "Java并发包源码学习之AQS框架（一）概述"
description: "Java并发包源码学习之AQS框架（一）概述"
categories: [articles]
tags: [Java,AQS]
alias: [/2015/03/10/]
utilities: fancybox,unveil,highlight
---

AQS其实就是`java.util.concurrent.locks.AbstractQueuedSynchronizer`这个类。
阅读Java的并发包源码你会发现这个类是整个`java.util.concurrent`的核心之一，也可以说是阅读整个并发包源码的一个突破口。

比如读`ReentrantLock`的源码你会发现其核心是它的一个内部类`Sync`:

<a class="post-image" href="/assets/images/posts/aqs-overview.png">
<img itemprop="image" data-src="/assets/images/posts/aqs-overview.png" src="/assets/js/unveil/loader.gif" alt="aqs-overview.png" />
</a>

整个包中很多类的结构都是如此，比如`Semaphore`,`CountDownLatch`都有一个内部类`Sync`，而所有的Sync都是继承自`AbstractQueuedSynchronizer`。
所以说想要读懂Java并发包的代码，首先得读懂这个类。

AQS的核心是通过一个共享变量来同步状态，变量的状态由子类去维护，而AQS框架做的是：

- 线程阻塞队列的维护
- 线程阻塞和唤醒

共享变量的修改都是通过`Unsafe`类提供的CAS操作完成的。`AbstractQueuedSynchronizer`类的主要方法是`acquire`和`release`，典型的模板方法，
下面这4个方法由子类去实现：

{% highlight Java %}

//独占模式获取
protected boolean tryAcquire(int arg)
//独占模式释放
protected boolean tryRelease(int arg)
//共享模式获取
protected int tryAcquireShared(int arg)
//共享模式释放
protected boolean tryReleaseShared(int arg)

{% endhighlight %}

	所谓独占就是一次只有一个线程能够获取资源，其他线程必须等它释放，共享则可以有多个线程同时获取到；
	公平和不公平讲的是多个线程同时去获取的时候是粗暴的抢占，还是按照一定的优先级来。

acquire方法用来获取锁，返回true说明线程获取成功继续执行，一旦返回false则线程加入到等待队列中，等待被唤醒，release方法用来释放锁。
一般来说实现的时候这两个方法被封装为`lock`和`unlock`方法。

下面的`SimpleLock`类实现了一个最简单非重入的互斥锁的功能，实际上它就是`ThreadPoolExecutor$Worker`的实现（以后的文章会提到这个类）。

{% highlight Java %}
class SimpleLock extends AbstractQueuedSynchronizer {
    private static final long serialVersionUID = -7316320116933187634L;

    public SimpleLock() {

    }

    protected boolean tryAcquire(int unused) {
        if (compareAndSetState(0, 1)) {
            setExclusiveOwnerThread(Thread.currentThread());
            return true;
        }
        return false;
    }

    protected boolean tryRelease(int unused) {
        setExclusiveOwnerThread(null);
        setState(0);
        return true;
    }

    public void lock() {
        acquire(1);
    }

    public boolean tryLock() {
        return tryAcquire(1);
    }

    public void unlock() {
        release(1);
    }

    public boolean isLocked() {
        return isHeldExclusively();
    }
} 
{% endhighlight %}

{% highlight Java %}
public static void main(String[] args) throws InterruptedException {
    final SimpleLock lock = new SimpleLock();
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
        // 简单的让线程按照for循环的顺序阻塞在lock上
        Thread.sleep(100);
    }

    System.out.println("main thread unlock!");
    lock.unlock();
} 
{% endhighlight %}


运行上面的测试代码，结果如下：

{% highlight Java %}
main thread unlock!
9 acquired the lock!
10 acquired the lock!
11 acquired the lock!
12 acquired the lock!
13 acquired the lock!
14 acquired the lock!
15 acquired the lock!
16 acquired the lock!
17 acquired the lock!
18 acquired the lock!
{% endhighlight %}

会发现等待的线程是按照阻塞时的顺序依次获取到锁的。
这是因为AQS是基于一个叫`CLH lock queue`的一个变种来实现线程阻塞队列的，我们下一篇文章就来简单了解下CLH lock queue。

后续文章计划如下：

- [《Java并发包源码学习之AQS框架（二）CLH lock queue和自旋锁》][2]
- [《Java并发包源码学习之AQS框架（三）LockSupport》][3]
- [《Java并发包源码学习之AQS框架（四）AbstractQueuedSynchronizer源码分析》][4]
- 《Java并发包源码学习之AQS框架（五）ConditionObject源码分析》

……

- 《Java并发包源码学习之锁（一）概述》
- 《Java并发包源码学习之锁（二）ReentrantLock源码分析》

……

- 《Java并发包源码学习之线程池（一）概述》
- 《Java并发包源码学习之线程池（二）ThreadPoolExecutor源码分析》

……

学习Java并发包源码的初衷是为了搞清之前遇到的[一个问题][1],其实很早之前就打算看这块的源码但一直没看下去，所以说
看源码一定要有目的不能为了看而看。


[1]: http://jindong.io/2015/01/20/concurrent-and-tomcat-threads/
[2]: http://jindong.io/2015/03/11/java-concurrent-package-aqs-clh-and-spin-lock/
[3]: http://jindong.io/2015/03/14/java-concurrent-package-aqs-locksupport-and-thread-interrupt/
[4]: http://jindong.io/2015/03/14/java-concurrent-package-aqs-AbstractQueuedSynchronizer/


