---
layout: post
title: "简单聊下Unicode和UTF-8"
description: "简单聊下Unicode和UTF-8"
categories: [notes]
tags: [Unicode]
alias: [/2014/11/29/]
utilities: fancybox, unveil
---

今晚听同事分享提到这个，简单总结下。

* Kramdown table of contents
{:toc .toc}

## Unicode字符集 
{: #unicode-charset}

`Unicode`的出现是因为ASCII等其他编码码不够用了，比如`ASCII`是英语为母语的人发明的，只要一个字节8位就能够表示26个英文字母了，但是当跨区域进行信息交流的时候，尤其是`Internet`的出现，除了“A”,“B”,“C"，还有“你”，“我”，“他”需要表示，一个字节8位显然不够用，因此`Unicode`就被发明出来，`Unicode`的最大码位`0x10FFFF`，有21位。中文对应的Unicode编码见[这里][1]。

## UTF-8字符编码
{: #coding}

Unicode只是给这世界上每个字符规定了一个统一的二进制编号，并没有规定程序该如何去存储和解析。

可以说`UTF-8`是`Unicode`实现方式之一，它的规则如下：

- 对于单字节的符号，字节的第一位设为0，后面7位为这个符号的`Unicode`码。因此对于英语字母，`UTF-8`编码和`ASCII`码是相同的。 
- 对于n字节的符号（n>1），第一个字节的前n位都设为1，第n+1位设为0，后面字节的前两位一律设为10。剩下的没有提及的二进制位，全部为这个符号的`Unicode`码。

<div class="data-table">
<table>
	<tr>
		<th>Unicode编码(十六进制)</th>
		<th>UTF-8 字节流(二进制)</th>
	</tr>
	<tr>
		<td>000000 - 00007F</td>
		<td>0xxxxxxx</td>
	</tr>
	<tr>
		<td>000080 - 0007FF</td>
		<td>110xxxxx 10xxxxxx</td>
	</tr>
	<tr>
		<td>000800 - 00FFFF</td>
		<td>1110xxxx 10xxxxxx 10xxxxxx</td>
	</tr>
	<tr>
		<td>010000 - 10FFFF</td>
		<td>11110xxx 10xxxxxx 10xxxxxx 10xxxxxx</td>
	</tr>
</table>
</div>

可以看到最多一共有21个x，所以刚好能够表示Unicode的最大的码位。

## 大端(BE)和小端(LE)
{: #big-endian-and-little-endian}

考虑4个字节的16进制表示`ox12345678`，计算机都是以字节为单位存储数据的，因此内存地址空间从低到高被挖成一个个“坑”，一个萝卜一个坑，那么相邻的萝卜之间自然就有顺序的问题。文字说明太抽象，直接看图理解。

<a class="post-image" href="/assets/images/posts/192305366258152.png">
<img itemprop="image" data-src="/assets/images/posts/192305366258152.png" src="/assets/js/unveil/loader.gif" alt="192305366258152.png" />
</a>

大端跟我们平时的书写习惯一致，比较好理解，记住大端就可以了，我们平时说的网络字节顺序也是指大端，至于小端就让它见鬼去吧。

实在要文字说明理解的话，可以这么来：大端可以认为是“高位在尾端”（大->高），“高位”指的是我们书写时的高位，比如1024,个十百千,1是高位，“尾端”指的是内存空间中低地址一端，所以1存储在低地址空间，只不过计算机是以一个字节为单位的。反之小端就是“低位在尾端”（小->低）了。

## BOM
{: #bom}

BOM(Byte Order Mark)是用来区分字节序列和编码方式的（UTF-8，UTF-16，UTF-32）。就是让编辑器或程序读到前面几个字节就知道后面该以哪种编码方式来解析，8/16/32是指以多少位作为编码单位的，依次就是1/2/4个字节，因为UTF-8是以单个字节作为编码单位的所以其实没有必要指定它的字节序列，所以UTF-8有BOM和无BOM的两种。

<div class="data-table">
<table>
	<tr>
		<th>UTF编码</th>
		<th>Byte Order Mark (BOM)</th>
	</tr>
	<tr>
		<td>UTF-8 without BOM</td>
		<td>无</td>
	</tr>
	<tr>
		<td>UTF-8 with BOM</td>
		<td>EF BB BF</td>
	</tr>
	<tr>
		<td>UTF-16LE</td>
		<td>FF FE</td>
	</tr>
	<tr>
		<td>UTF-16BE</td>
		<td>FE FF</td>
	</tr>
	<tr>
		<td>UTF-32LE</td>
		<td>FF FE 00 00</td>
	</tr>
	<tr>
		<td>UTF-32BE</td>
		<td>00 00 FE FF</td>
	</tr>
</table>
</div>

## 延伸阅读
{: #see-also}

[Unicode字符平面映射][2]


 [1]: http://www.chi2ko.com/tool/CJK.htm
 [2]: http://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84#.E5.9F.BA.E6.9C.AC.E5.A4.9A.E6.96.87.E7.A7.8D.E5.B9.B3.E9.9D.A2

