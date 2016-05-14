---
layout: post
title: "JVM内存调优相关的一些笔记（杂）"
description: "JVM内存调优相关的一些笔记（杂）"
categories: [notes]
tags: [JVM]
alias: [/2016/03/02/]
utilities: fancybox,unveil,highlight
---

Max memory = [-Xmx] + [-XX:MaxPermSize] + number_of_threads * [-Xss]

整个Java进程分为heap和non-heap两部分，每部分有以下几个概念：

<div class="data-table">
<table>
	<tr>
		<td>init</td>
		<td>represents the initial amount of memory (in bytes) that the Java virtual machine requests from the operating system for memory management during startup. The Java virtual machine may request additional memory from the operating system and may also release memory to the system over time. The value of init may be undefined.</td>
	</tr>
	<tr>
		<td>used</td>
		<td>represents the amount of memory currently used (in bytes).</td>
	</tr>
	<tr>
		<td>committed</td>
		<td>represents the amount of memory (in bytes) that is guaranteed to be available for use by the Java virtual machine. The amount of committed memory may change over time (increase or decrease). The Java virtual machine may release memory to the system and committed could be less than init. committed will always be greater than or equal to used.</td>
	</tr>
	<tr>
		<td>max</td>
		<td>represents the maximum amount of memory (in bytes) that can be used for memory management. Its value may be undefined. The maximum amount of memory may change over time if defined. The amount of used and committed memory will always be less than or equal to max if max is defined. A memory allocation may fail if it attempts to increase the used memory such that used > committed even if used <= max would still be true (for example, when the system is low on virtual memory).</td>
	</tr>
</table>
</div>
<br/>

reserved memory 是指JVM 通过mmaped PROT_NONE 申请的虚拟地址空间，在页表中已经存在了记录（entries），保证了其他进程不会被占用，会page faults,
committed memory 是JVM向操做系统实际分配的内存（malloc/mmap）,mmaped PROT_READ | PROT_WRITE,仍然会page faults 但是跟 reserved 不同，完全内核处理像什么也没发生一样。
used memory 是JVM实际存储了数据（Java对象）的大小，当used~=committed的时候，heap就会grow up，-Xmx设置了上限。

关于committed,reserved以及rss之间的关系实际情况要复杂的多：

- reserved 但是没有 committed pages 不算 rss.
- page out 的算committed，但是不算 rss.
- 已经 committed 的也不一定在rss内(committed > rss): malloc/mmap is lazy unless told otherwise. Pages are only backed by physical memory once they're accessed. 


committed 可能会比init小，因为JVM可能会将内存还给OS，但是一定不会小于used,也就是commited是操做系统保证JVM可以使用的内存空间，但是不一定都使用了。init是启动时后JVM向OS申请的内存，max是能够使用的最大边界值。注意这里说的都是虚拟内存，所以理论上整个操做系统commited的内存为物理内存加上交换空间的大小，换句话说如果commited超过物理内存的话，多余的部分就会被换出到磁盘。

JVM（堆）占用的物理内存是跟committed相关，committed变小意味着JVM将内存还给OS了，则同过top命令看到的RSS会变小。

测试发现：committed后的内存是不会还给OS的，FullGC后used（堆内存）降下来了，但是只要committed不变，占用的RSS就不会降下来。目前用的CMS也没有强制将内存还给OS的方法。
Java堆占用的物理内存不会超过-Xmx，但是一个进程具体占用多少物理内存不等于used，也不等于commited，目前来说JVM如何向OS申请内存和如何将内存还给OS我们是不知道的。

top命令查看到的RSS大于-Xmx设置的值，超过的部分肯定是堆外内存，如果大很多那说明对外内存使用的是有问题的。


**OS**

**commit charge**:

In thinking about virtual memory, there are two concepts that every programmer should understand: resident set size and commit charge. The second is easiest to explain: it's the total amount of memory that your program might be able to modify (ie, it excludes read-only memory-mapped files and program code). The potential commit charge for an entire system is the sum of RAM and swap space, and no program can exceed this. It doesn't matter how big your virtual address space is: if you have 2G of RAM, and 2G of swap, you can never work with more than 4G of in-memory data; there's no place to store it.

**dirty page**:

One final concept: pages in the resident set can be “dirty,” meaning that the program has changed their content. A dirty page must be written to swap space before its physical memory can be used by another page. By comparison, a clean (unmodified) page may simply be discarded; it will be reloaded from disk when needed. If you can guarantee that a page will never be modified, it doesn't count against a program's commit charge — we'll return to this topic when discussing memory-mapped files.


Below is a picture showing an example of a memory pool:

        +----------------------------------------------+
        +////////////////           |                  +
        +////////////////           |                  +
        +----------------------------------------------+

        |--------|
           init
        |---------------|
               used
        |---------------------------|
                  committed
        |----------------------------------------------|


通过jconsole的MBean可以很方便的监控heap,noheap以及commited,used这些内容：

<a class="post-image" href="/assets/images/posts/jconsole.png">
<img itemprop="image" data-src="/assets/images/posts/jconsole.png" src="/assets/js/unveil/loader.gif" alt="jconsole.png" />
</a>


JVM非堆的内存可能会有哪些？GC,JIT,Threads,Classes and Classloaders(PermGen),NIO(direct buffer)

But besides the memory consumed by your application, the JVM itself also needs some elbow room. The need for it derives from several different reasons:

- Garbage collection. As you might recall, Java is a garbage-collected language. In order for the garbage collector to know which objects are eligible for collection, it needs to keep track of the object graphs. So this is one part of the memory lost to this internal bookkeeping. G1 is especially known for its excessive appetite for additional memory, so be aware of this.

- JIT optimization. Java Virtual Machine optimizes the code during runtime. Again, to know which parts to optimize it needs to keep track of the execution of certain code parts. So again, you are going to lose memory.

- Off-heap allocations. If you happen to use off-heap memory, for example while using direct or mapped ByteBuffers yourself or via some clever 3rd party API then voila – you are extending your heap to something you actually cannot control via JVM configuration.

- JNI code. When you are using native code, for example in the format of Type 2database drivers, then again you are loading code in the native memory.

- Metaspace. If you are an early adopter of Java 8, you are using metaspace instead of the good old permgen to store class declarations. This is unlimited and in a native part of the JVM.

虚拟内存不重要，尤其是在64位操作系统上，重要的是RSS，但是有时它也不一定就说明你的程序实际需要使用的内存。JVM占用的物理内存超过-Xmx设置的值？

But RSS is also misleading, especially on a lightly loaded machine. The operating system doesn't expend a lot of effort to reclaiming the pages used be a process. There's little benefit to be gained by doing so, and the potential for an expensive page fault if the process touches the page in the future. As a result, the RSS statistic may include lots of pages that aren't in active use.


限制进程能够使用的物理内存：貌似不是很容易，主要原因是进程fork子进程

- http://unix.stackexchange.com/questions/44985/limit-memory-usage-for-a-single-linux-process

- http://coldattic.info/shvedsky/pro/blogs/a-foo-walks-into-a-bar/posts/40



**DirectByteBuffer**

Examining a heap dump for java.nio.DirectByteBuffer instances should provide further insight.

<a class="post-image" href="/assets/images/posts/direct-bytebuffer.png">
<img itemprop="image" data-src="/assets/images/posts/direct-bytebuffer.png" src="/assets/js/unveil/loader.gif" alt="direct-bytebuffer.png" />
</a>

-XX:MaxDirectMemorySize 可以限制JVM使用DirectMemory的大小。


jconsole non-heap memory:

**Non-heap memory** includes a method area shared among all threads and memory required for the internal processing or optimization for the Java VM. It stores per-class structures such as a runtime constant pool, field and method data, and the code for methods and constructors. The method area is logically part of the heap but, depending on the implementation, a Java VM may not garbage collect or compact it. Like the heap memory, the method area may be of a fixed or variable size. The memory for the method area does not need to be contiguous.


jconsole中看到的NonHeapMemory不包括direct buffer和mapped，可以通过java.nio中MBean监控，物理内存在linux下用top查看，在windows下任务管理器看到有些问题


<a class="post-image" href="/assets/images/posts/jconsole-direct-and-map.png">
<img itemprop="image" data-src="/assets/images/posts/jconsole-direct-and-map.png" src="/assets/js/unveil/loader.gif" alt="jconsole-direct-and-map.png" />
</a>

通过pmap能查看到mapped的文件：pamp -x <pid>:

<a class="post-image" href="/assets/images/posts/pmap.png">
<img itemprop="image" data-src="/assets/images/posts/pmap.png" src="/assets/js/unveil/loader.gif" alt="pmap.png" />
</a>

<a class="post-image" href="/assets/images/posts/pmap2.png">
<img itemprop="image" data-src="/assets/images/posts/pmap2.png" src="/assets/js/unveil/loader.gif" alt="pmap2.png" />
</a>

MappedByteBuffer和DirectByteBuffer虽然是堆外的内存但是通过FullGC是可以“回收”的。


Garbage Collection of Direct/Mapped Buffers

That brings up another topic: how does the non-heap memory for direct buffers and mapped files get released? After all, there's no method to explicitly close or release them. The answer is that they get garbage collected like any other object, but with one twist: if you don't have enough virtual memory space or commit charge to allocate a direct buffer, that will trigger a full collection even if there's plenty of heap memory available. Normally, this won't be an issue: you probably won't be allocating and releasing direct buffers more often than heap-resident objects. If, however, you see full GC's appearing when you don't think they should, take a look at your program's use of buffers.

使用Direct buffer的场景：

In fact, the only reason that I can see for using direct buffers in a pure Java program is that they won't be moved during garbage collection. If you've read my article on reference objects, you'll remember that the garbage collector compacts the heap after disposing of dead objects. If you have large blocks of heap memory allocated as buffers, they may get moved as part of compaction, and no matter how fast your CPU, that takes time; it's not something you want to do on every full collection. Since the direct buffer lives outside of the heap, it isn't affected by collections. On the other hand, every data access is a JNI call. Only benchmarking will tell you whether this helps or hurts your particular application.

What's using my native memory?

Once you have determined you are running out of native memory, the next logical question is: What's using that memory? Answering this question is hard because, by default, Windows and Linux do not store information about which code path is allocated a particular chunk of memory.

如何监控和排查non-heap 或 native memory leak

- IBM Support Assistant: https://www-01.ibm.com/marketing/iwm/iwm/web/reg/download.do?source=isa&S_PKG=isa5&lang=en_US&cp=UTF-8&dlmethod=http
- Preprocessor level: Dmalloc 
- Linker level:  Ccmalloc 
- Runtime-linker level: NJAMD 
- Emulator-based:  memcheck
- JNI leaking: Valgrind memcheck http://www.oracle.com/technetwork/java/javase/memleaks-137499.html#gbyvk
- Java core file: http://www.javacodegeeks.com/2013/02/analysing-a-java-core-dump.html
- NMT Native Memory Tracking: https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/tooldescr007.html 注意目前（7u40）NMT只能用来分析HotSpot internal memory usage，不能分析第三方的JNI.
- GCMV: https://www.ibm.com/developerworks/java/jdk/tools/gcmv/ https://www.ibm.com/developerworks/community/blogs/troubleshootingjava/entry/gcmv_native_memory?lang=en

相比分析堆内存的泄漏，分析non-heap的要困难的多，不同的场景需要不同的工具去分析。


一些链接：

http://www.ibm.com/developerworks/linux/library/j-nativememory-linux/

http://docs.oracle.com/javase/7/docs/api/java/lang/management/MemoryUsage.html

http://stackoverflow.com/questions/561245/virtual-memory-usage-from-java-under-linux-too-much-memory-used

http://stackoverflow.com/questions/1612939/why-does-the-sun-jvm-continue-to-consume-ever-more-rss-memory-even-when-the-heap

(下面这两个答案很有用)

https://plumbr.eu/blog/memory-leaks/why-does-my-java-process-consume-more-memory-than-xmx

http://www.importnew.com/14292.htm

