---
layout: post
title: "Windows 下安装 gRPC"
description: "Windows 下安装 gRPC"
categories: [notes]
tags: [grpc]
alias: [/2015/03/19/]
utilities: fancybox,unveil,highlight
---

gRPC是Google最近才发布的一个基于[HTTP/2][11]和[Protocol Buffer][3]的RPC框架。

项目地址：[https://github.com/grpc/grpc-java][12]。

[官方文档][1]其实说的比较清楚，但它主要针对的Linux，Winows下面安装稍微麻烦点，
我这边梳理下。

* Kramdown table of contents
{:toc .toc}


## 环境准备
{: #env}

### Gradle 安装
{: #gradle-install}

因为`GRPC`工程是基于Gradle的，所以需要先安装它，把它理解为类似Maven的工具，
比较简单就啰嗦了。[下载地址][2]，我安装的是2.3版本。


### Maven 安装
{: #maven-install}

需要3.2版本，如果你不是的话更新下就可以，安装也很简单不赘述了。


## protobuf 编译
{: #compiler-protobuf}

关于`protobuf`的内容可以看我[前一篇的博客][3]，这一步很重要，上一篇提到的`protoc.exe`编译程序也是这步来的，
官方说需要`3.0.0-alpha-2`那么直接就[下载这个版本][4]的代码，不要`git clone` master了，否则编译的时候需要
一个`gtest`的目录，`master`没有这个目录还要下载。

代码下载下来之后直接用`Visual Studio`（各个版本都行VS会自己转换）打开就可以。

<a class="post-image" href="/assets/images/posts/protobuf-vsproject.png">
<img itemprop="image" data-src="/assets/images/posts/protobuf-vsproject.png" src="/assets/js/unveil/loader.gif" alt="protobuf-vsproject.png" />
</a>

选择`Release`模式编译，正常情况应该很顺利就编译完成了。编译完成后主要是`libprotobuf.lib`，`libprotobuf-lite.lib`，`libprotoc.lib`和`protoc.exe`
这四个库或程序后面需要用到。

### mvn install protobuf-java 和 protobuf-javanano 工程
{: #install-protobuf-java-and-javanano}

`GRPC`安装依赖这两个工程，`javanano`可能需要另外[下载][5]。先将上面编译出来的`protoc.exe`复制到`$PROTOBUF_HOME$\src`(protobuf-3.0.0-alpha-2\src)目录下，
然后分别打开`$PROTOBUF_HOME$\java`和`$PROTOBUF_HOME$\javanano`目录下的pom文件，搜索`../src/protoc`替换为`../src/protoc.exe`，
然后分别instal：

{% highlight Shell %}
cd java
mvn install

cd ../javanano
mvn install
{% endhighlight %}

其实这两个工程[Maven中央仓库][6]都有，可以直接从中央仓库下载。


## GRPC 编译
{: #grpc-compiler}

一切都准备好后就可以编译GRPC了。

### 源码下载
{: #source-download}

{% highlight Shell %}
$ git clone https://github.com/grpc/grpc-java.git
{% endhighlight %}


### Netty 和 HTTP/2 依赖安装
{: #dependencies}

GRPC依赖`netty4.1+`和`codec-http2 `（HTTP/2的介绍可以看我[之前的一篇博客][7]）。

{% highlight Shell %}
$ git submodule update --init
$ cd lib/netty
$ mvn install -pl codec-http2 -am -DskipTests=true
{% endhighlight %}

### 编译
{: #do-compiling-grpc}

编译过程中`gradle wrapper`需要到[这里][8]下载gradle，最好全程[科学上网][9]。实在没办法可以先下好gradle，修改
`gradle-wrapper.properties`如下：

{% highlight Shell %}
#Tue Jan 27 15:29:30 PST 2015
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
#distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
distributionUrl=gradle-2.3-all.zip
{% endhighlight %}


windows下编译需要指定protobuf源码和编译出来的库文件，在grpc工程根目录创建文件`gradle.properties`，写入内容：

	protobuf.include=C:\\path\\to\\protobuf-3.0.0-alpha-2\\src
	protobuf.libs=C:\\path\\to\\protobuf-3.0.0-alpha-2\\vsprojects\\Release

编译`grpc-java`工程：

{% highlight Shell %}
$ gradle install
{% endhighlight %}


到目前为止还算顺利，但是，但是……目前其中有一个子模块`compiler`（protobuf_plugin）貌似只支持`Linux`下编译：

	## System Requirement

	* Linux
	* The Github head of [Protobuf](https://github.com/google/protobuf) installed
	* [Gradle](https://www.gradle.org/downloads) installed


因为`benchmarks\`和`examples\`都依赖`protobuf_plugin`,所以也都无法正常编译。


官方也明确说明了[https://github.com/grpc/grpc-java/issues/87][10]不支持：

	Building on Windows with gradle doesn't currently work. Getting gradle set up correctly is a bit more involved than we thought.However, one can work around this issue by manually building the plugin with Visual Studio.

一个解决办法就是跟上面编译protobuf一样需要手动用VS编译`protobuf_plugin`。或者忽视这几个工程，核心的部分还是可以编译成功的。

### 手动编译 protobuf_plugin
{: #compiler-protobuf-plugin-with-vs}

不折腾了……

网上搜了一圈还没找到在`Windows`上编译成功GRPC的，看来我是第一批吃螃蟹的人之一，在官方完全支持windows前还是乖乖滚回Linux吧~



[1]: https://github.com/grpc/grpc-java#start-of-content
[2]: https://gradle.org/downloads
[3]: http://jindong.io/2015/03/15/google-protocol-buffers-java-tutorial/
[4]: https://github.com/google/protobuf/releases/download/v3.0.0-alpha-2/protobuf-java-3.0.0-alpha-2.zip
[5]: https://github.com/google/protobuf/releases/download/v3.0.0-alpha-2/protobuf-javanano-3.0.0-alpha-2.zip
[6]: http://search.maven.org/#search%7Cga%7C1%7Cprotobuf-java
[7]: http://jindong.io/2015/03/09/new-technique-in-new-year-HTTP2/
[8]: https://services.gradle.org/distributions/gradle-2.2.1-all.zip
[9]: http://www.cnblogs.com/zhanjindong/p/useful-tools.html
[10]: https://github.com/grpc/grpc-java/issues/87
[11]: http://jindong.io/2015/03/09/new-technique-in-new-year-HTTP2/
[12]: https://github.com/grpc/grpc-java