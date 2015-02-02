---
layout: post
title: "可惜Java中没有yield return"
description: "可惜Java中没有yield return"
categories: [articles]
tags: [Java]
alias: [/2013/09/01/]
utilities: fancybox, unveil, highlight
---

{% highlight %}
uid　　caller
123456　　12345678901
789101　　12345678901
……
{% endhighlight %}


现在要做的就是读取文件中的每一个用户然后给他推消息，具体的逻辑可能要复杂点，但今天关心的是如何遍历文件返回用户信息的问题。

之前用C#已经写过类似的代码，大致如下：

{% highlight C# %}
/// <summary>
        /// 读取用户清单列表，返回用户信息。
        /// </summary>
        /// <param name="parameter">用户清单文件路径</param>
        /// <param name="position">推送断点位置，用户断点推送</param>
        /// <returns></returns>
        public IEnumerable<UserInfo> Provide(string parameter, int position)
        {
            FileStream fs = new FileStream(parameter, FileMode.Open);
            StreamReader reader = null;
            try
            {
                reader = new StreamReader(fs);
                //获取文件结构信息
                string[] schema = reader.ReadLine().Trim().Split(' ');
                for (int i = 0; i < position; i++)
                {
                    //先空读到断点位置
                    reader.ReadLine();  
                }
                while (!reader.EndOfStream)
                {
                    UserInfo userInfo = new UserInfo();
                    userInfo.Fields = new Dictionary<string, string>();
                    string[] field = reader.ReadLine().Trim().Split(' ');
                    for (int i = 0; i < schema.Length; i++)
                    {
                        userInfo.Fields.Add(schema[i].ToLower(), field[i]);
                    }

                    yield return userInfo;
                }
            }
            finally
            {
                reader.Close();
                fs.Close();
            }
        }
{% endhighlight %}

代码很简单，就是读取清单文件返回用户信息，需要注意的就是标红的地方，那么yield return的作用具体是什么呢。对比下面这个版本的代码：

{% highlight C# %}
public IEnumerable<UserInfo> Provide2(string parameter, int position)
        {
            List<UserInfo> users = new List<UserInfo>();
            FileStream fs = new FileStream(parameter, FileMode.Open);
            StreamReader reader = null;
            try
            {
                reader = new StreamReader(fs);
                //获取文件结构信息
                string[] schema = reader.ReadLine().Trim().Split(' ');
                for (int i = 0; i < position; i++)
                {
                    //先空读到断点位置
                    reader.ReadLine();
                }
                while (!reader.EndOfStream)
                {
                    UserInfo userInfo = new UserInfo();
                    userInfo.Fields = new Dictionary<string, string>();
                    string[] field = reader.ReadLine().Trim().Split(' ');
                    for (int i = 0; i < schema.Length; i++)
                    {
                        userInfo.Fields.Add(schema[i].ToLower(), field[i]);
                    }

                    users.Add(userInfo);
                }

                return users;
            }
            finally
            {
                reader.Close();
                fs.Close();
            }
        }
{% endhighlight %}

本质区别是第二个版本一次性返回所有用户的信息，而第一个版本实现了惰性求值（Lazy Evaluation），针对上面的代码简单调试下，你会发现同样是通过foreach进行迭代，第一个版本每次代码运行到yield return userInfo的时候会将控制权交给“迭代”它的地方，而后面的代码会在下次迭代的时候继续运行。

{% highlight C# %}
static void Main(string[] args)
        {
            string filePath = @"D:\users.txt";

            foreach (var user in new FileProvider().Provide(filePath,0))
            {
                Console.WriteLine(user);
            }
        }
{% endhighlight %}

而第二个版本则需要等所有用户信息全部获取到才能返回。相比之下好处是显而易见的，比如前者占用更小的内存，cpu的使用更稳定：

<a class="post-image" href="/assets/images/posts/01131056-d559bf0a08814e3cacf3676ad3ea0039.png">
<img itemprop="image" data-src="/assets/images/posts/01131056-d559bf0a08814e3cacf3676ad3ea0039.png" src="/assets/js/unveil/loader.gif" alt="01131056-d559bf0a08814e3cacf3676ad3ea0039.png" />
</a>

<a class="post-image" href="/assets/images/posts/01131109-16c5dcebd6dd4519a7b1d42fc848a0c5.png">
<img itemprop="image" data-src="/assets/images/posts/01131109-16c5dcebd6dd4519a7b1d42fc848a0c5.png" src="/assets/js/unveil/loader.gif" alt="01131109-16c5dcebd6dd4519a7b1d42fc848a0c5.png" />
</a>

当然做到这点是需要付出**代价**(维护状态)，真正的好处也并不在此。之前我在博客中对C#的yield retrun有一个[简单的总结][1]，但是并没有深入的研究：

- IEnumerable是对IEnumerator的封装，以支持foreach语法糖。
- IEnumerable<T>和IEnumerator<T>分别继承自IEnumerable和IEnumerator以提供强类型支持(即状态机中的“现态”是强类型)。
- yield return是编译器对IEnumerator和IEnumerable实现的语法糖。
- yield return 表现是实现IEnumerator的MoveNext方法，本质是实现一个状态机。
- yield return能暂时将控制权交给外部，我比作“程序上奇点”，让你实现穿越。能达到目的：延迟计算、异步流。

先看第1条，迭代器模式是大部分语言都支持一个设计模式，它是一种行为模式:

> 行为模式是一种简化对象之间通信的设计模式。

