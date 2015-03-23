---
layout: post
title: "对协变和逆变的简单理解"
description: "对协变和逆变的简单理解"
categories: [articles]
tags: [C#]
alias: [/2013/04/13/]
utilities: fancybox,unveil,highlight
---

毕业快一年了，边工作边学习，虽说对.net不算精通，但也算入门了，但一直以来对协变和逆变这个概念不是太了解，上学时候mark了一些文章，今天回过头看感觉更糊涂了，真验证本人一句口头禅“知道的越多，知道的越少”。看到最后实在乱了，就干脆装糊涂好了，本人也算半个阴谋论者，在编程语言这方面当我实在没法吃透一个语法的时候，我就归咎于编译器这个幕后黑手。我们看下面两个类Derived派生自Base:

{% highlight C# %}
public class Base
{
}

public class Derived:Base
{
}
{% endhighlight %}

我们都这知道下面这两行代码，第一行能编译通过，第二行则无法编译通过：

{% highlight C# %}
Base b=new Derived();
Derived d = new Base();
{% endhighlight %}

当我们尝试编译第二行代码的时候，编译器会提示我们缺少一个显示类型转换。那我们加上强制类型转换后自然就没问题了。

{% highlight C# %}
Derived d = (Derived)new Base();
{% endhighlight %}

Why?其实原因很简单，因为C#语言规范就是这样的，编译器就是这么处理的。这有点像宇宙学中的“人择原理”，当我弄不清楚一个问题我就放空自己。当然随着人类慢慢探索，对宇宙的了解越来越多，宇宙是现在这样是有它的道理的，编译器这样处理也是有它道理的。下面说下自己对上面为什么子类对象能赋值给父类变量而父类对象不能赋给子类变量的粗俗理解（不谈多态）。

每个对象本质上都是内存中的一块地址空间，当然不同对象占用的地址空间不同。我们声明一个对象后Base  b=new Derived() ，怎么访问这块地址空间呢？当然就是通过那个“变量”b。变量的类型就决定了这个变量能“看到”多大的地方,变量就是查看对象的一双“眼睛”。子类继承自父类，子类的对象比父类的对象要大些。

<a class="post-image" href="/assets/images/posts/13212823-14500c20a8ce40c3ae5d89c13d04221a.png">
<img itemprop="image" data-src="/assets/images/posts/13212823-14500c20a8ce40c3ae5d89c13d04221a.png" src="/assets/js/unveil/loader.gif" alt="13212823-14500c20a8ce40c3ae5d89c13d04221a.png" />
</a>

父类对象变量的“视角”要比子类对象变量“视角”小。当我们把子类对象赋个父类变量的时候：

{% highlight C# %}
Base b=new Derived();
{% endhighlight %}

<a class="post-image" href="/assets/images/posts/13213555-5a6a7bd1c55442a5917567406a7f56b6.png">
<img itemprop="image" data-src="/assets/images/posts/13213555-5a6a7bd1c55442a5917567406a7f56b6.png" src="/assets/js/unveil/loader.gif" alt="13213555-5a6a7bd1c55442a5917567406a7f56b6.png" />
</a>

变量b只会看到它能看到的东西，换句话说指针不会访问到未知的区域，所以这种类型的隐式转换是安全的，编译器允许这么做。

反过来如果把一个父类对象赋给子类的变量:

{% highlight C# %}
Derived d = new Base();
{% endhighlight %}

<a class="post-image" href="/assets/images/posts/13214314-36490df6380045a69cb92694309704df.png">
<img itemprop="image" data-src="/assets/images/posts/13214314-36490df6380045a69cb92694309704df.png" src="/assets/js/unveil/loader.gif" alt="13214314-36490df6380045a69cb92694309704df.png" />
</a>

因为子类变量的视野范围超过了父类对象的大小，就会看到了不该看到了，换句话说，指针能访问到不该访问的区域，这被认为是不安全的，因此编译器不允许这么做。

那么这和协变和逆变又有什么关系呢？个人认为协变逆变不过是一种隐式类型转换，.net4.0通过in和out关键字保证了在泛型接口和委托上对这种安全的允许的隐式转换的支持。下面以委托做简单的说明。

先看协变：

{% highlight C# %}
public delegate T Function<out T>();
public delegate void Operate<in T>(T instance);
{% endhighlight %}

{% highlight C# %}
static void Main(string[] args)
{

            Function<Derived> funDer = new Function<Derived>(() => { return new Derived(); });
            Function<Base> funBase = funDer;

            Base b = funBase.Invoke();
}
{% endhighlight %}

首先我想说明下，之前看网上有人说**Function<Base> funBase = funDer;**这句是“子类对象赋值给父类的变量(这里幸好是委托，如果是接口可能更容易这么觉得)，父类调用子类的方法，体现了多态。”因此就得出观点：“协变体现了多态性”。个人认为这里根本不存在多态的概念，funBase和funDer根本就不是父子类的关系何来多态，相反这里体现的面相对象的另一个特性继承。本质上就是上面提到的Base b = funBase.Invoke();这里可以安全的进行从Derived到Base的转换，b不会看到不该看到的。

再来看下逆变：
{% highlight C# %}
Operate<Base> opBase = new Operate<Base>(x => { Console.WriteLine(x.ToString()); });
Operate<Derived> opDer = opBase;

opDer.Invoke(new Derived());
{% endhighlight %}

同样有人说这里**Operate<Derived> opDer = opBase;**是“父类变量赋值给子类变量，是4.0种出现的新的特性，以前没见过。”事实上呢？事实上这里才真正体现了多态性。**x => { Console.WriteLine(x.ToString());**这里x只会以父类的视角去看传递给该方法的参数，只会看到子类中它能看到的（包括重载的方法），这不正是多态的体现吗？当然也是因为符合上面我提到的类型之间安全的隐式转换，所以编译器自然支持这种“逆变”。

泛型接口中的协变和逆变理解起来更难点（一个原因我想是更容易让人跟传统的继承、多态联系在一起了），但本质上是一样的。

以上就是我个人对协变和逆变的一些肤浅的理解。其实很多人我想都被这两个忒专业的术语吓到了，如果真的理解不了那就暂且不去了解，F1看MSDN：

> Covariance permits a method to have return type that is more derived than that defined in the delegate. Contravariance permits a method that has parameter types that are less derived than those in the delegate type. —— MSDN