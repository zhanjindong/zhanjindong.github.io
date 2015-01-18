---
layout: post
title: "【开源一个小工具】一键将网页内容推送到Kindle"
description: "【开源一个小工具】一键将网页内容推送到Kindle"
categories: [articles]
tags: [Kindle]
alias: [/2014/12/11/]
utilities: fancybox, unveil
---

最近工作上稍微闲点，这一周利用下班时间写了一个小工具，其实功能挺简单但也小折腾了会。

**工具名称**：Simple Send to Kindle

**Github地址**：[https://github.com/zhanjindong/SimpleSendToKindle][1]

**功能**：Windows下一个简单的将网页内容推送到Kindle的工具。

写这个工具的是满足自己的需求。自从买了Kindle paperwhite 2，它就成了我使用率最高的一个电子设备。相信很多Kindle拥有者和我一样都有这样一个需求：就是白天网上看到了一些好文章没时间看，就想把它推送到Kindle上，晚上睡觉前躺在床上慢慢看。之前我一直用的是一个叫KindleMii的工具，但是发现经常推送的内容图片丢失了，Chrome应用商店里有一个叫做Send to Kindle的工具但是装了之后不知道什么原因用不了，于是我就想不如自己动手写一个，名字就叫Simple Send to Kindle。

## 原理
原理很简单，就是通过Chrome扩展程序将网页链接发送给本地的一个Java写的程序，这个程序将网页内容下载下来并转换为Kindle的mobi格式，然后再通过kindle的邮箱发送给Kindle设备。

工具的核心功能是利用Amazon提供的一个叫kindlegen的程序生成mobi文件，大家也可以离线使用这个工具将网页内容生成各种Kindle支持的格式，另外一个核心是Chrome扩展和本地程序的Native Messaging，这个浪费了我挺长时间，后面会简单介绍下。

## 如何使用
1、用mvn assembly打包，打包后目录如下：

<a class="post-image" href="/assets/images/posts/112049477124106.png">
<img itemprop="image" data-src="/assets/images/posts/112049477124106.png" src="/assets/js/unveil/loader.gif" alt="112049477124106.png" />
</a>

2、工具可以放到任何地方，然后执行setup.bat这个脚本。

3、安装Chrome扩展。在Chrome里输入chrome://extension就可以进入扩展管理：点加载正在开发的扩展程序，选择ext下的Chrome目录就可以以开发者模式加载扩展程序了，可以看到每个扩展都有一个唯一标识ID，这个后面配置会用到。

<a class="post-image" href="/assets/images/posts/112109106961572.png">
<img itemprop="image" data-src="/assets/images/posts/112109106961572.png" src="/assets/js/unveil/loader.gif" alt="112109106961572.png" />
</a>

加载成功就可以在浏览器地址栏右边看到这个logo了：

<a class="post-image" href="/assets/images/posts/112114065251250.png">
<img itemprop="image" data-src="/assets/images/posts/112114065251250.png" src="/assets/js/unveil/loader.gif" alt="112114065251250.png" />
</a>

4、工具已经安装成功了下面进行一些简单配置就可以了：
1)打开SimpleSendToKindle.json这个文件：将allowed_origins里面的内容修改为上面Chrome扩展的ID。

<a class="post-image" href="/assets/images/posts/112118103687744.png">
<img itemprop="image" data-src="/assets/images/posts/112118103687744.png" src="/assets/js/unveil/loader.gif" alt="112118103687744.png" />
</a>

2)sstk.properties里面是一些工具的通用配置：
{% highlight C# %}
#整个服务的超时时间
sstk.service.timeout = 120000
#网页内容或图片的下载超时时间
sstk.download.timeout = 15000
#是否删除临时目录
sstk.download.deleteTmpDir = false

mail.smtp.starttls.enable=true
mail.smtp.socketFactory.port=25
mail.smtp.host=smtp.126.com
mail.host=smtp.126.com
mail.smtp.auth=true
mail.transport.protocol=smtp
mail.userName=XXX
mail.password=iflytek
mail.from=XXX@126.com
mail.to=XXX@kindle.cn

#debug
sstk.debug.sendMail = false
{% endhighlight %}

主要配置的就是邮箱这块，mail.to配置是你的Kindle邮箱，mail.from是用来发送的邮箱，我这里用的是126，其他邮箱也都支持smtp，有Kindle的同学都知道要想Kindle收到邮件发送的内容必须将发送油箱添加到Amazon认可的邮箱列表中。

<a class="post-image" href="/assets/images/posts/112126370562006.png">
<img itemprop="image" data-src="/assets/images/posts/112126370562006.png" src="/assets/js/unveil/loader.gif" alt="112126370562006.png" />
</a>

都配置好后看到你想要推送的页面，只要轻轻点击下就Ok了。

<a class="post-image" href="/assets/images/posts/112131018686575.png">
<img itemprop="image" data-src="/assets/images/posts/112131018686575.png" src="/assets/js/unveil/loader.gif" alt="112131018686575.png" />
</a>

稍等片刻，查看你的Kindle，效果如下：

<a class="post-image" href="/assets/images/posts/112339164781856.png">
<img itemprop="image" data-src="/assets/images/posts/112339164781856.png" src="/assets/js/unveil/loader.gif" alt="112339164781856.png" />
</a>

<a class="post-image" href="/assets/images/posts/112339402123972.png">
<img itemprop="image" data-src="/assets/images/posts/112339402123972.png" src="/assets/js/unveil/loader.gif" alt="" />
</a>

## 遇到的一些问题
工具虽然简单，但是从思路到成型，过程也遇到了一些问题，这里跟大家分享下，有兴趣的同学可以接着往下看。

### 实现思路
有了想法后首先要想的就是实现思路，一开始想用JavaScript写，最后只要安装一个Chrome扩展程序就可以了，这样肯定是Simple的，但是最后还是放弃这个想法，一来我对JS基本不会，二来写这个工具的目的是为了满足自己的需求，怎么快怎么来，什么技术熟悉就用什么，所以最后还是决定用Chrome扩展和Java程序通信这种方式。但这过程发现了一些很有用的工具，我在最后会推荐给大家。
