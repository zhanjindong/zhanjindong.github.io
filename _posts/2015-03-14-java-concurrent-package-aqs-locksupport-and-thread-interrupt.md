---
layout: post
title: "Java并发包源码学习之AQS框架（三）LockSupport和interrupt"
description: "Java并发包源码学习之AQS框架（三）LockSupport和interrupt"
categories: [articles]
tags: [Java,AQS,LockSupport]
alias: [/2015/03/14/]
utilities: fancybox,unveil,highlight,show-hidden
---

接着[上一篇文章][1]今天我们来介绍下`LockSupport`和Java中线程的`中断（interrupt）`。

其实除了LockSupport，Java之初就有`Object`对象的wait和notify方法可以实现线程的阻塞和唤醒。那么它们的区别
是什么呢？

主要的区别应该说是它们面向的对象不同。阻塞和唤醒是对于线程来说的，LockSupport的park/unpark更符合这个语义，以“线程”作为方法的参数，
语义更清晰，使用起来也更方便。而wait/notify的实现使得“阻塞/唤醒对线程本身来说是被动的，要准确的控制哪个线程、什么时候阻塞/唤醒很困难，
要不随机唤醒一个线程（notify）要不唤醒所有的（notifyAll）。


<a class="post-image" href="/assets/images/posts/park-vs-wait.png">
<img itemprop="image" data-src="/assets/images/posts/park-vs-wait.png" src="/assets/js/unveil/loader.gif" alt="park-vs-wait.png" />
</a>


`wait/notify`最典型的例子应该就是生产者/消费者了：

{% highlight Java %}
class BoundedBuffer1 {
    private int contents;

    final Object[] items = new Object[100];
    int putptr, takeptr, count;

    public synchronized void put(Object x) {
        while (count == items.length) {
            try {
                wait();
            } catch (InterruptedException e) {
            }
        }

        items[putptr] = x;
        if (++putptr == items.length)
            putptr = 0;
        ++count;
        notifyAll();
    }

    public synchronized Object take() {
        while (count == 0) {
            try {
                wait();
            } catch (InterruptedException e) {
            }
        }
        Object x = items[takeptr];
        if (++takeptr == items.length)
            takeptr = 0;
        --count;
        notifyAll();
        return x;
    }

    public static class Producer implements Runnable {

        private BoundedBuffer1 q;

        Producer(BoundedBuffer1 q) {
            this.q = q;
            new Thread(this, "Producer").start();
        }

        int i = 0;

        public void run() {
            int i = 0;
            while (true) {
                q.put(i++);
            }
        }
    }

    public static class Consumer implements Runnable {

        private BoundedBuffer1 q;

        Consumer(BoundedBuffer1 q) {
            this.q = q;
            new Thread(this, "Consumer").start();
        }

        public void run() {
            while (true) {
                System.out.println(q.take());
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        final BoundedBuffer1 buffer = new BoundedBuffer1();
        new Thread(new Producer(buffer)).start();
        new Thread(new Consumer(buffer)).start();
    }
} 
{% endhighlight %}

上面的例子中有一点需要知道，在调用对象的`wait`之前当前线程必须先释放该对象的监视器（`synchronized`），被唤醒之后需要重新获取到监视器才能继续执行。

{% highlight Java %}
//wait会先释放当前线程拥有的监视器
obj.wait();
//会re-acquire监视器 	
{% endhighlight %}

而`LockSupport`并不需要获取对象的监视器。LockSupport机制是每次`unpark`给线程1个“许可”——最多只能是1，而`park`则相反，如果当前
线程有许可，那么park方法会消耗1个并返回，否则会阻塞线程直到线程重新获得许可，在线程启动之前调用`park/unpark`方法没有任何效果。

{% highlight Java %}
// 1次unpark给线程1个许可
LockSupport.unpark(Thread.currentThread());
// 如果线程非阻塞重复调用没有任何效果
LockSupport.unpark(Thread.currentThread());
// 消耗1个许可
LockSupport.park(Thread.currentThread());
// 阻塞
LockSupport.park(Thread.currentThread()); 	
{% endhighlight %}

因为它们本身的实现机制不一样，所以它们之间没有交集，也就是说LockSupport阻塞的线程，notify/notifyAll没法唤醒。


实际上现在很少能看到直接用wait/notify的代码了，即使生产者/消费者也基本都会用`Lock`和`Condition`来实现，我会在后面《Java并发包源码学习之AQS框架（五）ConditionObject源码分析》
文章中再回头看这个例子。

总结下`LockSupport`的`park/unpark`和`Object`的`wait/notify`：

- 面向的对象不同；
- 跟Object的wait/notify不同LockSupport的park/unpark不需要获取对象的监视器；
- 实现的机制不同，因此两者没有交集。


虽然两者用法不同，但是有一点，`LockSupport`的park和Object的wait一样也能响应中断。

{% highlight Java %}
public static void main(String[] args) throws InterruptedException {
    final Thread t = new Thread(new Runnable() {
        @Override
        public void run() {
            LockSupport.park();
            System.out.println("thread " + Thread.currentThread().getId() + " awake!");
        }
    });

    t.start();
    Thread.sleep(3000);

    // 2. 中断
    t.interrupt();
} 
{% endhighlight %}

	thread 9 awake!

在我之前的[一篇博客][2]“如何正确停止一个线程”有介绍过`Thread.interrupt()`

> Thread.interrupt()方法不会中断一个正在运行的线程。这一方法实际上完成的是，在线程受到阻塞时抛出一个中断信号，这样线程就得以退出阻塞的状态。更确切的说，如果线程被Object.wait, Thread.join和Thread.sleep三种方法之一阻塞，那么，它将接收到一个中断异常（InterruptedException），从而提早地终结被阻塞状态。


`LockSupport.park()`也能响应中断信号，但是跟`Thread.sleep()`不同的是它不会抛出`InterruptedException`，
那怎么知道线程是被unpark还是被中断的呢，这就依赖线程的**interrupted status**，如果线程是被中断退出阻塞的那么该值被设置为true，
通过Thread的`interrupted`和`isInterrupted`方法都能获取该值，两个方法的区别是`interrupted`获取后会Clear，也就是将**interrupted status**重新置为false。

AQS和Java线程池中都大量用到了中断，主要的作用是唤醒线程、取消任务和清理（如ThreadPoolExecutor的shutdown方法），AQS中的`acquire`方法也有中断和不可中断两种。
其中对于`InterruptedException`如何处理最重要的一个原则就是**Don't swallow interrupts**，一般两种方法：

- 继续设置interrupted status
- 抛出新的InterruptedException

{% highlight Java %}
try {
    ………
} catch (InterruptedException e) {
    // Restore the interrupted status
    Thread.currentThread().interrupt();
    // or thow a new
    //throw new InterruptedException();
} 
{% endhighlight %}

AQS的`acquire`就用到了第一种方法。

关于`InterruptedException`处理的最佳实践可以看[IBM的这篇文章][3]。



最后按照惯例做下引申。上面`BoundedBuffer1`类的`put`和`take`方法中的wait为什么要放在一个while循环里呢？
你如果去看`Object.wait()`方法的Javadoc的话会发现官方也是建议下面这样的用法：

{% highlight Java %}
synchronized (obj) {
    while (<condition does not hold>)
        ……
        obj.wait();
	……
}
 
{% endhighlight %}


StackOverflow上有一个问题里一个叫[xagyg的回答][4]解释的比较清楚，有兴趣的可以看下。
简单来说因为：

wait前会释放监视器，被唤醒后又要重新获取，这瞬间可能有其他线程刚好先获取到了监视器，从而导致状态发生了变化，
这时候用while循环来再判断一下条件（比如队列是否为空）来避免不必要或有问题的操作。
这种机制还可以用来处理伪唤醒（spurious wakeup），所谓伪唤醒就是`no reason wakeup`，对于`LockSupport.park()`来说就是除了`unpark`和`interrupt`之外的原因。


`LockSupport`也会有同样的问题，所以看AQS的源码会发现很多地方都有这种re-check的思路，我们下一篇文就来看下`AbstractQueuedSynchronizer`类的源码。





[1]: http://jindong.io/2015/03/11/java-concurrent-package-aqs-clh-and-spin-lock/
[2]: http://www.cnblogs.com/zhanjindong/p/3515234.html
[3]: http://www.ibm.com/developerworks/java/library/j-jtp05236/index.html
[4]: http://stackoverflow.com/questions/37026/java-notify-vs-notifyall-all-over-again


