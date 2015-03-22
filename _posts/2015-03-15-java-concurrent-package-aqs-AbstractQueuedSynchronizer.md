---
layout: post
title: "Java并发包源码学习之AQS框架（四）AbstractQueuedSynchronizer源码分析"
description: "Java并发包源码学习之AQS框架（四）AbstractQueuedSynchronizer源码分析"
categories: [articles]
tags: [Java,AQS,AbstractQueuedSynchronizer]
alias: [/2015/03/15/]
utilities: fancybox,unveil,highlight
---

经过前面几篇文章的铺垫，今天我们终于要看看`AQS`的庐山真面目了，建议第一次看`AbstractQueuedSynchronizer`
类源码的朋友可以先看下我前面几篇文章：

- [《Java并发包源码学习之AQS框架（一）概述》][1]
- [《Java并发包源码学习之AQS框架（二）CLH lock queue和自旋锁》][2]
- [《Java并发包源码学习之AQS框架（三）LockSupport》][3]

分析源码是非常枯燥的一件事，主要就是贴源码加上一些注释。
因为`AbstractQueuedSynchronizer`上千行代不需要每行都要读懂，所以只捡一些关键的地方做说明，
有一些地方可能我理解的有出入，欢迎大家指正。详细的注释我都放在了[GitHub上][4]。


前面提到`AQS`是基于[CLH lock queue][2]的，`AbstractQueuedSynchronizer`是通过一个内部类`Node`实现了一个变种。
前面基本说明了Node的主要内容，但这个类还有一些其他重要的字段：

{% highlight Java %}
//标记当前结点是共享模式
static final Node SHARED = new Node();

//标记当前结点是独占模式
static final Node EXCLUSIVE = null;

//结点的等待状态。
volatile int waitStatus;

//拥有当前结点的线程。
volatile Thread thread;
{% endhighlight %}

其中`waitStatus`很重要，用来控制线程的阻塞/唤醒，以及避免不必要的调用LockSupport的park/unpark方法。
它主要有以下几个取值：


{% highlight Java %}
//代表线程已经被取消
static final int CANCELLED = 1;

//代表后续节点需要唤醒
static final int SIGNAL = -1;

//代表线程在condition queue中，等待某一条件
static final int CONDITION = -2;

//代表后续结点会传播唤醒的操作，共享模式下起作用
static final int PROPAGATE = -3;
{% endhighlight %}


## 出队操作

只要设置新的`head`结点就可以了。

{% highlight Java %}
private void setHead(Node node) {
    head = node;
    node.thread = null;
    node.prev = null;
} 
{% endhighlight %}


## 入队操作

{% highlight Java %}
private Node addWaiter(Node mode) {
    Node node = new Node(Thread.currentThread(), mode);
    // Try the fast path of enq; backup to full enq on failure
    Node pred = tail;
    // 这个if分支其实是一种优化：CAS操作失败的话才进入enq中的循环。
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    enq(node);
    return node;
} 

private Node enq(final Node node) {
    for (;;) {
        Node t = tail;
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
                return t;
            }
        }
    }
} 
{% endhighlight %}

## 独占模式获取

{% highlight Java %}
public final void acquire(int arg) {
    // tryAcquire 由子类实现本身不会阻塞线程，如果返回 true,则线程继续，
    // 如果返回 false 那么就 
    加入阻塞队列阻塞线程，并等待前继结点释放锁。
    if (!tryAcquire(arg) && acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        // acquireQueued返回true，说明当前线程被中断唤醒后获取到锁，
        // 重置其interrupt status为true。
        selfInterrupt();
} 
{% endhighlight %}

一旦tryAcquire成功则立即返回，否则线程会加入队列 线程可能会反复的被阻塞和唤醒直到tryAcquire成功，这是因为线程可能被中断，
而acquireQueued方法中会保证忽视中断，只有tryAcquire成功了才返回。中断版本的独占获取是`acquireInterruptibly`这个方法，
`doAcquireInterruptibly`这个方法中如果线程被中断则`acquireInterruptibly`会抛出`InterruptedException`异常。


`addWaiter`方法只是入队操作，`acquireQueued`方法是主要逻辑，需要重点理解。


{% highlight Java %}
final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        boolean interrupted = false;
        // 等待前继结点释放锁
        // 自旋re-check
        for (;;) {
            // 获取前继
            final Node p = node.predecessor();
            // 前继是head,说明next就是node了，则尝试获取锁。
            if (p == head && tryAcquire(arg)) {
                // 前继出队，node成为head
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }

            // p != head 或者 p == head但是tryAcquire失败了，那么
            // 应该阻塞当前线程等待前继唤醒。阻塞之前会再重试一次，还需要设置前继的waitStaus为SIGNAL。
            
	    // 线程会阻塞在parkAndCheckInterrupt方法中。
            // parkAndCheckInterrupt返回可能是前继unpark或线程被中断。
            if (shouldParkAfterFailedAcquire(p, node) && parkAndCheckInterrupt())
                // 说明当前线程是被中断唤醒的。
                // 
                注意：线程被中断之后会继续走到if处去判断，也就是会忽视中断。
                // 除非碰巧线程中断后acquire成功了，那么根据Java的最佳实践，
                // 需要重新设置线程的中断状态（acquire.selfInterrupt）。
                interrupted = true;
        }
    }
    finally {
        // 出现异常
        if (failed)
            cancelAcquire(node);
    }
} 
{% endhighlight %}

基本每行都有注释，但得结合`shouldParkAfterFailedAcquire`和`parkAndCheckInterrupt`这两个方法来一起理解会更
容易些。shouldParkAfterFailedAcquire方法的作用是：

- 确定后继是否需要park;
- 跳过被取消的结点;
- 设置前继的waitStatus为SIGNAL.


{% highlight Java %}
int ws = pred.waitStatus;
if (ws == Node.SIGNAL)// 前继结点已经准备好unpark其后继了，所以后继可以安全的park
    /*
     * This node has already set status asking a release to signal it,
     * so it can safely park.
     */
    return true;
if (ws > 0) {// CANCELLED
    // 跳过被取消的结点。
    do {
        node.prev = pred = pred.prev;
    } while (pred.waitStatus > 0);
    pred.next = node;
} else {// 0 或 PROPAGATE (CONDITION用在ConditonObject，这里不会是这个值)
    /**
     * waitStatus 等于0（初始化）或PROPAGATE。说明线程还没有park，会先重试 
     * 确定无法acquire到再park。
     */

    // 更新pred结点waitStatus为SIGNAL
    compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
}
return false; 
{% endhighlight %}

parkAndCheckInterrupt就是用[LockSupport][3]来阻塞当前线程，很简单：


{% highlight Java %}
private final boolean parkAndCheckInterrupt() {
    LockSupport.park(this);
    return Thread.interrupted();
}  
{% endhighlight %}

线程被唤醒只可能是：被`unpark`，被中断或伪唤醒。被中断会设置`interrupted`，acquire方法返回前会
`selfInterrupt`重置下线程的中断状态，如果是伪唤醒的话会for循环re-check。


## 独占模式释放

比较简单只要直接唤醒后续结点就可以了，后续结点会从`parkAndCheckInterrupt`方法中返回。

{% highlight Java %}
public final boolean release(int arg) {
    // tryReease由子类实现，通过设置state值来达到同步的效果。
    if (tryRelease(arg)) {
        Node h = head;
        // waitStatus为0说明是初始化的空队列
        if (h != null && h.waitStatus != 0)
            // 唤醒后续的结点
            unparkSuccessor(h);
        return true;
    }
    return false;
} 
{% endhighlight %}


## 共享模式获取

`acquireShared`方法是用来共享模式获取。

{% highlight Java %}
public final void acquireShared(int arg) {
    //如果没有许可了则入队等待
    if (tryAcquireShared(arg) < 0)
        doAcquireShared(arg);
} 

private void doAcquireShared(int arg) {
    // 添加队列
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        boolean interrupted = false;
        // 等待前继释放并传递
        for (;;) {
            final Node p = node.predecessor();
            if (p == head) {
                int r = tryAcquireShared(arg);// 尝试获取
                if (r >= 0) {
                    // 获取成功则前继出队，跟独占不同的是
                    // 会往后面结点传播唤醒的操作，保证剩下等待的线程能够尽快 获取到剩下的许可。
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    if (interrupted)
                        selfInterrupt();
                    failed = false;
                    return;
                }
            }

            // p != head || r < 0
            if (shouldParkAfterFailedAcquire(p, node) && parkAndCheckInterrupt())
                interrupted = true;
        }
    }
    finally {
        if (failed)
            cancelAcquire(node);
    }
} 
{% endhighlight %}

核心是这个`doAcquireShared`方法，跟独占模式的`acquireQueued`很像，主要区别在`setHeadAndPropagate`方法中，
这个方法会将node设置为head。如果当前结点acquire到了之后发现还有许可可以被获取，则继续释放自己的后继，
后继会将这个操作传递下去。这就是`PROPAGATE`状态的含义。


{% highlight Java %}
private void setHeadAndPropagate(Node node, int propagate) {
    Node h = head; // Record old head for check below
    setHead(node);
    /*
     * 尝试唤醒后继的结点：<br />
     * propagate > 0说明许可还有能够继续被线程acquire;<br />
     * 或者 之前的head被设置为PROPAGATE(PROPAGATE可以被转换为SIGNAL)说明需要往后传递;<br />
     * 或者为null,我们还不确定什么情况。 <br />
     * 并且 后继结点是共享模式或者为如上为null。
     * <p>
     * 上面的检查有点保守，在有多个线程竞争获取/释放的时候可能会导致不必要的唤醒。<br />
     * 
     */
    if (propagate > 0 || h == null || h.waitStatus < 0) {
        Node s = node.next;
        // 后继结是共享模式或者s == null（不知道什么情况）
        // 如果后继是独占模式，那么即使剩下的许可大于0也不会继续往后传递唤醒操作
        // 即使后面有结点是共享模式。
        if (s == null || s.isShared())
            // 唤醒后继结点
            doReleaseShared();
    }
} 

private void doReleaseShared() {
    for (;;) {
        Node h = head;
        // 队列不为空且有后继结点
        if (h != null && h != tail) {
            int ws = h.waitStatus;
            // 不管是共享还是独占只有结点状态为SIGNAL才尝试唤醒后继结点
            if (ws == Node.SIGNAL) {
                // 将waitStatus设置为0
                if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                    continue; // loop to recheck cases
                unparkSuccessor(h);// 唤醒后继结点
                // 如果状态为0则更新状态为PROPAGATE，更新失败则重试
            } else if (ws == 0 && !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                continue; // loop on failed CAS
        }
        // 如果过程中head被修改了则重试。
        if (h == head) // loop if head changed
            break;
    }
} 
{% endhighlight %}

## 共享模式释放

主要逻辑也就会`doReleaseShared`。

{% highlight Java %}
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
} 
{% endhighlight %}


独占和共享模式除了对应的中断版本，还有超时版本，整体代码相差不大，具体再赘述了。提前前面文章
中提到的`自旋`，好像目前整个AQS中都没用到这个功能，accquire中for循环主要作用不是为了自旋，那么
它用在什么地方呢？AQS中有一个变量：

	static final long spinForTimeoutThreshold = 1000L;

这个变量用在`doAcquireNanos`方法，也就是支持超时的获取版本。

{% highlight Java %}
private boolean doAcquireNanos(int arg, long nanosTimeout) throws InterruptedException {
    long lastTime = System.nanoTime();
    final Node node = addWaiter(Node.EXCLUSIVE);
    boolean failed = true;
    try {
        for (;;) {
            final Node p = node.predecessor();
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return true;
            }
            if (nanosTimeout <= 0)// 超时
                return false;
            // nanosTimeout > spinForTimeoutThreshold
            // 如果超时时间很短的话，自旋效率会更高。
            if (shouldParkAfterFailedAcquire(p, node) && nanosTimeout > spinForTimeoutThreshold)
                LockSupport.parkNanos(this, nanosTimeout);
            long now = System.nanoTime();
            nanosTimeout -= now - lastTime;
            lastTime = now;
            if (Thread.interrupted())
                throw new InterruptedException();
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
} 
{% endhighlight %}


AQS的的主要内容其实差不多看完了，但是上面的逻辑中waitStatus中有一个状态还没涉及到那就是`CONDITION`，
下一篇博客《Java并发包源码学习之AQS框架（五）ConditionObject源码分析》中会介绍它。


[1]: http://jindong.io/2015/03/10/java-concurrent-package-aqs-overview/
[2]: http://jindong.io/2015/03/11/java-concurrent-package-aqs-clh-and-spin-lock/
[3]: http://jindong.io/2015/03/14/java-concurrent-package-aqs-locksupport-and-thread-interrupt/
[4]: https://github.com/zhanjindong/ReadTheJDK/blob/master/src/main/java/java/util/concurrent/locks/AbstractQueuedSynchronizer.java
