---
layout: post
title: "TCP&IP相关"
description: "TCP&IP相关"
categories: [notes]
tags: [TCP&IP]
alias: [/2015/01/18/]
---
# TCP&IP相关

标签（空格分隔）： TCP/IP

---
## TCP Flags

## TCP Options
`EOF` End of Option List.标识TCP选项列表结束。

`NOP` No Operation(used for padding).用来字节填充，因为TCP头部必须是字节的整数倍。

`MMS` Maxumum Segment Size.TCP报文段最大的大小，只是TCP数据部分的大小，不包括TCP头部和IP头部，IPv4通常是1460，IPv6通常是1440，少20因为一般MTU为1500，而IPv6头部比IPv4多20bytes

`WSOPT` Windows Scaling Factor(left-shift amount window).主要是为了扩展滑动窗口的大小，因为TCP头部中window size只有16位,通过这个“乘数”（左移）能使窗口大小达到差不多1G

`SACK-Permitted` Sender supports SACK options.标识发送方支持SACK。

`SACK` SACK block(out-of-order data recevied).主要是为配合滑动窗口，因为窗口的存在接收方接收到的数据可能是乱序的，为了提高性能，ACK时可以通过SACK选项说明已经接收到哪些连续seq number（因为TCP Options大小有限制，最多只能说明3个这样的连续块，叫SACK Block），这样接收方可以更好的选择重发哪些seq number的segment。

`TSOPT` Timestaps option.时间戳，这个时间戳只是相对的概念，发送方和接受方不需要同步，各自维护就可以了，单调递增。这个选项有两部分组成，发送方把自己的时间戳放在第一部分，接收方接收到的时候，把发送的时间戳原封不动的挪到第二个部分，再在第一部分放上自己的时间戳，这样依次交互下去。时间戳的作用，一是为了估算TTL，主要用途在拥塞控制算法上；另一个作用是我们都知道seq number做多只有32位，这样在传输很大数据（6G）、窗口很大（1G）以及传输速度很快的情况下可能会出现，之前的丢失的segment（通过重发机制已经传送过去了）跟后面的某个segment的seq number一样，这时候接收方根据比较发送方的时间戳就知道这个“老”数据无效了，这叫Protection Against Wrapped Sequence Numbers。

`UTO` User Timeout(abort after idle time). 简单来说就是等待ACK的超时时间，如果发送方超过这个时间还没等到ACK就会重传，这个时间至少要比重传的超时时间(RTO)要长，因为超过这个时间就认为发送失败会关闭连接（？）。UTOs不能太长，太长可能导致资源容易被耗尽，也不能太短，太短可能导致连接被提前关闭。另外需要注意的是这个选项只是给连接各端的一个建议值，最终使用的USER_TIMEOUT不能保证一定是这个选项设置的值，实现的时候一般会根据系统本身的设置等进行选择，大概如下的公式：
`USER_TIMEOUT = min(U_LIMIT,max(ADV_UTO,REMOTE_UTO,L_LIMIT))`
`ADV_UTO`是一端给对端设置的值，`REMOTE_UTO`是对端的设置的值，`U_LIMIT`是本地系统设置的最大值，L_LIMIT是最小值。

`TCP-AO` Authentication options(using various algorithms).用来替代之前的TCP-MD5，以提高TCP的安全性。这个选项比较新还没有广泛使用。简单说就是每次传输之前，两端需要先通过某种方式交换一些共享的key，然后每次都用不同的共享key(in-band signaling)并用一种特殊的哈希算法(RFC5926)计算segment的hash值（？）来检查segment在传输过程有没有被修改。关键是如何创建和共享这些key。

2个`Experimental` Reserved for experimental use.保留作为实验用途。

-----

`MTU`




