---
layout: post
title: "【开源一个小工具】一键将网页内容推送到Kindle"
description: "【开源一个小工具】一键将网页内容推送到Kindle"
categories: [articles]
tags: [Kindle]
alias: [/2014/12/11/]
utilities: fancybox, unveil, highlight, show-hidden
---

最近工作上稍微闲点，这一周利用下班时间写了一个小工具，其实功能挺简单但也小折腾了会。

**工具名称**：Simple Send to Kindle

**Github地址**：[https://github.com/zhanjindong/SimpleSendToKindle][1]

**功能**：Windows下一个简单的将网页内容推送到Kindle的工具。

写这个工具的是满足自己的需求。自从买了Kindle paperwhite 2，它就成了我使用率最高的一个电子设备。相信很多Kindle拥有者和我一样都有这样一个需求：就是白天网上看到了一些好文章没时间看，就想把它推送到Kindle上，晚上睡觉前躺在床上慢慢看。之前我一直用的是一个叫KindleMii的工具，但是发现经常推送的内容图片丢失了，Chrome应用商店里有一个叫做Send to Kindle的工具但是装了之后不知道什么原因用不了，于是我就想不如自己动手写一个，名字就叫Simple Send to Kindle。

* Kramdown table of contents
{:toc .toc}

## 原理
{: #principle}

原理很简单，就是通过Chrome扩展程序将网页链接发送给本地的一个Java写的程序，这个程序将网页内容下载下来并转换为Kindle的mobi格式，然后再通过kindle的邮箱发送给Kindle设备。

工具的核心功能是利用Amazon提供的一个叫kindlegen的程序生成mobi文件，大家也可以离线使用这个工具将网页内容生成各种Kindle支持的格式，另外一个核心是Chrome扩展和本地程序的Native Messaging，这个浪费了我挺长时间，后面会简单介绍下。

## 如何使用
{: #how-to}

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
{: #some-questions}

工具虽然简单，但是从思路到成型，过程也遇到了一些问题，这里跟大家分享下，有兴趣的同学可以接着往下看。

### 实现思路
有了想法后首先要想的就是实现思路，一开始想用JavaScript写，最后只要安装一个Chrome扩展程序就可以了，这样肯定是Simple的，但是最后还是放弃这个想法，一来我对JS基本不会，二来写这个工具的目的是为了满足自己的需求，怎么快怎么来，什么技术熟悉就用什么，所以最后还是决定用Chrome扩展和Java程序通信这种方式。但这过程发现了一些很有用的工具，我在最后会推荐给大家。

### Chrome扩展开发
我一直用的都是chrome，所以想到了开发Chrome下的插件（Chrome下叫Extension扩展）。那首先要解决的就是如何开发Chrome插件？开发chrome扩展很简单，官方有一个入门例子非常简单，[一看就懂][1]。 这里推荐园子里的一篇文章：[Chrome插件（Extensions）开发攻略][2]。

### Chrome扩展和本地程序通信
官方术语叫做`Native Messaging`，具体技术细节这里不啰嗦了，有兴趣的同学可以网上搜下，这里指简单介绍下。chrome扩展在Windows下是通过HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\这个注册表下面的内容和一个.json的清单文件来找到你的`Native App`的。上面的`setup.bat`就是用来写入注册表的，`SimpleSendToKind.json`就是清单文件：

{% highlight bat %}
@echo off
reg add HKEY_CURRENT_USER\Software\Google\Chrome\NativeMessagingHosts\so.zjd.sstk /ve /t REG_SZ /d %~dp0\SimpleSendToKindle.json /f
{% endhighlight %}

`setup.ba`t将`so.zjd.sstk`这个“程序”注册到chrome关心的注册表下，Chrome通过它找到标识应用程序信息的清单文件：

{% highlight json %}
{
    "name":"so.zjd.sstk",
    "description":"Simple Send to Kindle(by zjd.so)",
    "path":"startup.exe",
        "type":"stdio",
    "allowed_origins":[
        "chrome-extension://jnihbngmnjbmchfhcdfabofamnfcljaf/"

    ]
}
{% endhighlight %}

path是本地程序的路径，除了注意程序的权限问题外，还要注意这里path里面如果有路径分隔符必须是双斜杠“//”。

Chrome是通过系统的标准输入输出和本地程序进行通信，具体协议如下：

> Chrome 浏览器在单独的进程中启动每一个原生消息通信宿主，并使用标准输入（stdin）与标准输出（stdout）与之通信。向两个方向发送消息时使用相同的格式：每一条消息使用 JSON 序列化，以 UTF-8 编码，并在前面附加 32 位的消息长度（使用本机字节顺序）。

协议其实很简单，但是这块却浪费了我好长时间，我用Java死活无法读取Chrome写入标准输入的内容，总是报下面的错误：

<a class="post-image" href="/assets/images/posts/112211153535342.png">
<img itemprop="image" data-src="/assets/images/posts/112211153535342.png" src="/assets/js/unveil/loader.gif" alt="" />
</a>

一开始怀疑自己的写的代码有问题，网上搜了半天有说是JDK的问题，我重装还是不行。后来我发现Chrome传给程序其实有两个参数，一个windwos的句柄，一个Chrome扩展的ID：
{% highlight c#%}
arg 0:--parent-window=3349886
arg 1:chrome-extension://oojaanpmaapemaihjbebgojmblljbhhh/
{% endhighlight %}

所以我就想Java能不能直接从Windows句柄读数据，因为Java确实提供了一个FileDescriptor类，但折腾了半天发现原生的Java并不支持这么干。最后没办法下，想出了非常丑陋的解决办法，利用C#来做下中转，所以才多了个startup.exe，C#代码写的很顺利，这也让我对Java是累感不爱啊。

<a class="show-hidden">{{ site.translations.show }}</a> 
{% hide %} 
{% highlight c# %} 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace Startup
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                if (!Directory.Exists(System.AppDomain.CurrentDomain.BaseDirectory + "\\log"))
                {
                    Directory.CreateDirectory(System.AppDomain.CurrentDomain.BaseDirectory + "\\log");
                }

                if (args.Length == 0)
                {
                    WriteStandardStreamOut("Missing parameter.");
                    Log2File("Missing parameter.");
                    return;
                }

                string url = ReadStandardStreamIn();
                Log2File("Running SimpleSendToKindle.jar with url:" + url);
                string ret = RunJar(url);
                Log2File("Completed with return msg:" + ret);
                WriteStandardStreamOut("{\"text\":\"" + ret + "\"}");
            }
            catch (Exception ex)
            {
                Log2File("Error:" + ex.ToString());
                WriteStandardStreamOut("{\"text\":\"" + "Error." + ex.Message + "\"}");
            }
        }

        static string RunJar(string arg)
        {
            ProcessStartInfo startInfo = new ProcessStartInfo()
            {
                WorkingDirectory = System.AppDomain.CurrentDomain.BaseDirectory,
                UseShellExecute = false,//要重定向 IO 流，Process 对象必须将 UseShellExecute 属性设置为 False。
                CreateNoWindow = true,
                RedirectStandardOutput = true,
                //RedirectStandardInput = false,
                WindowStyle = ProcessWindowStyle.Normal,
                FileName = "java.exe",
                Arguments = @" -Dfile.encoding=utf-8 -jar SimpleSendToKindle.jar " + arg,
            };
            //启动进程
            using (Process process = Process.Start(startInfo))
            {
                process.Start();
                //process.WaitForExit();
                using (StreamReader reader = process.StandardOutput)
                {
                    return reader.ReadToEnd();
                }
            }
        }

        static void Log2File(string s)
        {
            FileStream fs = new FileStream(System.AppDomain.CurrentDomain.BaseDirectory + @"log/startup.log", FileMode.Append);
            StreamWriter sw = new StreamWriter(fs, Encoding.UTF8);
            sw.WriteLine(s);
            sw.Close();
            fs.Close();
        }

        static string ReadStandardStreamIn()
        {
            using (Stream stdin = Console.OpenStandardInput())
            {
                int length = 0;
                byte[] bytes = new byte[4];
                stdin.Read(bytes, 0, 4);
                length = System.BitConverter.ToInt32(bytes, 0);

                byte[] msgBytes = new byte[length];
                stdin.Read(msgBytes, 0, length);

                string decodeMsg = Microsoft.JScript.GlobalObject.decodeURI(System.Text.Encoding.UTF8.GetString(msgBytes));
                return decodeMsg;
            }
        }

        static void WriteStandardStreamOut(string msg)
        {
            int length = msg.Length;
            byte[] lenBytes = System.BitConverter.GetBytes(length);
            byte[] msgBytes = System.Text.Encoding.UTF8.GetBytes(msg);
            byte[] wrapBytes = new byte[4 + length];
            Array.Copy(lenBytes, 0, wrapBytes, 0, 4);
            Array.Copy(msgBytes, 0, wrapBytes, 4, length);

            using (Stream stdout = Console.OpenStandardOutput())
            {
                stdout.Write(wrapBytes, 0, wrapBytes.Length);
            }
        }
    }
}
{% endhighlight %} 
{% endhide %}

### Chrome扩展获取当前页面的url
园子里那个例子里是在content_script.js里用document.URL，但是我发现这有个问题，每次必须重新加载页面，不然这个值好像全局就一个。发现用chrome.tabs.getSelected这个事件监听更好些：

<a class="show-hidden">{{ site.translations.show }}</a> 
{% hide %} 
{% highlight javascript %} 
chrome.tabs.getSelected(null,function(tab) {
    var port = null;
    var nativeHostName = "so.zjd.sstk";
    port = chrome.runtime.connectNative(nativeHostName);

    port.onMessage.addListener(function(msg) { 
        //console.log("Received " + msg); 
        $("#message").text(msg.text);
    });

    port.onDisconnect.addListener(function onDisconnected(){
        //console.log("connetct native host failure:" + chrome.runtime.lastError.message);
        port = null;
        //$("#message").text("Finished!");
    });
     
    port.postMessage(encodeURI(tab.url)) 

});

popup.js
{% endhighlight %} 
{% endhide %}

### 图片解析
其实右键将网页另存为为html后就能利用kindlegen生成mobi文件了，或者利用Amazon的邮箱服务直接将html文件发送给Kindle，也能自动转换成mobi。但是之所以要写这个工具的原因就是kindlegen也好，kindle邮箱服务也好都不会去主动下载页面里的图片，kindlegen需要你将页面里图片或其他资源的地址转换成相对路径，然后将资源统一放在一个文件家里。

<a class="post-image" href="/assets/images/posts/112227135716583.png">
<img itemprop="image" data-src="/assets/images/posts/112227135716583.png" src="/assets/js/unveil/loader.gif" alt="" />
</a>

<a class="post-image" href="/assets/images/posts/112228305718840.png">
<img itemprop="image" data-src="/assets/images/posts/112228305718840.png" src="/assets/js/unveil/loader.gif" alt="" />
</a>

所以处理也很简单解析页面img元素内容，自己将图片下载下来然后将src替换成相对路径就OK了，需要注意的就是网页图片引用的几种方式：http://www.test.com/dir1/dir2/test.html

{% highlight C# %}
./images/mem/figure9.png  →  http://www.test.com/dir1/dir2/images/mem/figure9.png
images/mem/figure9.png    →  http://www.test.com/dir1/dir2/images/mem/figure9.png
/images/mem/figure9.png   →  http://www.test.com/images/mem/figure9.png
../../images/mem/figure9.png  →  http://www.test.com/figure.png 
{% endhighlight %}

.表示当前目录
..表示上级目录
代码大致如下：

<a class="show-hidden">{{ site.translations.show }}</a> 
{% hide %} 
{% highlight java %} 
private String processRelativeUrl(String url) {
        if (url.startsWith("http://")) {
            return url;
        }
        String pageUrl = this.page.getUrl();
        int relative = 0;
        int index = 0;
        if (url.startsWith("/")) {
            relative = -1;
        } else {
            while (true) {
                index = 0;
                if (url.startsWith("./")) {// 当前目录
                    index = url.indexOf("./");
                    url = url.substring(index + 2);
                    continue;
                } else if (url.startsWith("../")) {// 上级目录
                    relative++;
                    index = url.indexOf("../");
                    url = url.substring(index + 3);
                    continue;
                } else {// 当前目录
                    break;
                }
            }
        }
        if (relative == -1) {
            index = pageUrl.indexOf('/', 7);
            pageUrl = pageUrl.substring(0, index);
            url = url.substring(1);
        } else {
            for (int i = 0; i <= relative; i++) {
                index = pageUrl.lastIndexOf("/");
                if (index == -1) {
                    break;
                }
                pageUrl = pageUrl.substring(0, index);
            }
        }
        url = pageUrl + "/" + url;

        return url;
    }

popup.js
{% endhighlight %} 
{% endhide %}

本来是打算也处理CSS的，结果发现CSS反而会导致生成的mobi格式错乱就算了。

### 页面乱码
有的网页的meta元素并不规范会导致kindlegen生成的mobi文件乱码，比如：

	<meta charset="UTF-8">

需要处理下：
	
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

### 一些网站防止恶意抓取的问题
有些网站的页面为了防止网络爬虫恶意抓取内容会对HTTP请求的User-Agent进行简单验证，这种情况简单模拟下浏览器的UA就可以绕过了，这也说明了恶意的抓取确实很难杜绝，前几天园子里好像还有人提到这个。这里有个疑问：到底什么样的行为算恶意抓取，就我本人来说肯定不会有任何恶意。

<a class="post-image" href="/assets/images/posts/112244162757158.png">
<img itemprop="image" data-src="/assets/images/posts/112244162757158.png" src="/assets/js/unveil/loader.gif" alt="" />
</a>

## 存在的问题

写的比较匆忙，还存在很多问题：

1、Chrome插件没界面、没用户体验，只是为了实现功能；

2、需要C#程序来做中转，这个太恶心了，结果工具一点也不simple；

3、有的中文网页会导致生成的mobi文件乱码，肯定是网页编码方便的问题，有时间再看看；

4、生成的mobi文件比较大，可以考虑对内容进行裁剪；

5、不支持将页面选中的内容推送到Kindle；

6、如果页面有代码或排版不好，显示比较乱，可读性比较差；

7、未考虑Kindle不支持的图片格式，其实大部分情况就哪几种图片;

8、Linux平台支持，其实kindlegen有linux下的版本，Chrome扩展本身在什么平台下都能用。

另外才关注开源没多久，Github上提交的代码质量有待提高。

## 一些资源
前面提到写这个工具的过程中其实发掘了一些很不错的工具和服务，这里推荐给大家：
. [KDP(Amazon Kindle Direct Publishing)][3]:亚马逊提供的一个服务。
. [HTML-to-MOBI][4]:一个在线的将网页转换成mobi文件的服务，但是好像图片处理也有问题。
. [用JS将markdown转成mobi，epub等电子书格式。][5]
. [Java mobi metadata editor][6]:一个小工具可以用来编辑mobi的元数据。
. [kindle book development tool][7]:貌似是一个收费的工具。
. Calibre:一个非常强大的免费电子书管理和生成工具，推荐这篇文章[抓取网页内容生成Kindle电子书][8]。
. [RssToMobiService][9]:Github上一个抓取RSS生成mobi文件发送到Kindle的工具，很不错的。

## 写在最后
今天写完才发现，原来Amazon官方就有一个插件叫Send to Kindle，而且支持各种浏览器，很好很强大，需要的同学直接用官方的吧，这么晚码字很辛苦，没有功劳也有苦劳，如果觉得不错给个推荐吧~

写这个工具最大的收获就是：有想法就去做，just do it!

 [1]: http://chrome.liuyixi.com/getstarted.html。
 [2]: http://www.cnblogs.com/guogangj/p/3235703.html
 [3]: https://kdp.amazon.com/help?topicId=A1KSPVAI36UUC1
 [4]: http://www.office-converter.com/HTML-to-MOBI
 [5]: https://www.npmjs.com/package/ebook
 [6]: http://www.mobileread.com/forums/showthread.php?p=1927698
 [7]: http://www.kindlewriter.co.uk/
 [8]: http://blog.codinglabs.org/articles/convert-html-to-kindle-book.html
 [9]: http://blog.csdn.net/yanghua_kobe/article/details/18950969