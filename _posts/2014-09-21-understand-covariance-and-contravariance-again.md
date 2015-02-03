---
layout: post
title: "再谈对协变和逆变的理解"
description: "再谈对协变和逆变的理解"
categories: [articles]
tags: [Java]
alias: [/2014/09/21/]
utilities: fancybox,unveil,highlight
---

之前写过[一篇博客][1]谈了下我自己对协变和逆变的理解，现在回头看发现当时还是太过“肤浅”，根本没理解。不久前还写过一篇“黑”Java泛型的博客，猛一回头又是“肤浅”，今天学习Java泛型的时候又看到了协变和逆变，感觉又理解了点，记录一下，但不免还是“肤浅”，看了这篇博客的同学，欢迎留言交流下。

* Kramdown table of contents
{:toc .toc}

## 什么是协变和逆变
{: #what-is-covariance-and-contravariance}

到底什么是协变和逆变？先看例子：

{% highlight Java %}
//Java
Object[] objects = new String[2];
//C# 
object[] objects = new string[2];
{% endhighlight %}


这就是协变，C#和Java都是支持`数组协变`的语言，好像说了等于没说，别急，慢慢来。

我们都知道C#和Java中String类型都是继承自Object的，姑且记做`String ≦ Objec`t，表示String是Object的子类型，String的对象可以赋给Object的对象。

而Object的数组类型Object[]，我们可以理解成是由Object构造出来的一种新的类型,可以认为是一种`构造类型`，记f(Object)（可以类比下初中数学中函数的定义），那么我们可以这么来描述协变和逆变：

- 当A ≦ B时,如果有f(A) ≦ f(B),那么f叫做**协变**；
- 当A ≦ B时,如果有f(B) ≦ f(A),那么f叫做**逆变**；
- 如果上面两种关系都不成立则叫做**不可变**。

其实顾名思义，协变和逆变表示的一种类型转变的关系：“构造类型”之间相对“子类型”之间的一种关系。只不过平时我（可能也包括大家）被网上的一些文章搞糊涂了。“协”表示一种自然而然的转换关系，比如上面的`String[] ≦ Object[`]，这就是大家学习面向对象编程语言中经常说的：

> 子类变量能赋给父类变量，父类变量不能赋值给子类变量。

而“逆”则不那么直观，平时用的也很少，后面讲`Java泛型中的协变和逆变`会看到例子。

`不可变`的例子就很多了，比如Java中`List<Object>`和`List<String>`之间就是不可变的。

{% highlight Java %}
List<String> list1 = new ArrayList<String>();
List<Object> list2 = list1;
{% endhighlight %}

这两行代码在Java中肯定是编译不过的，反过来更不可能，C#中也是一样。

那么`协变`和`逆变`作用到底是什么呢？我个人肤浅的理解：主要是语言设计的一种考量，目的是为了增加语言的灵活性和能力。

## 里氏替换原则
{: #liskov-principle}

再说下面内容之前，提下这个大家都知道的原则：

>  有使用父类型对象的地方都可以换成子类型对象。

假设有类Fruit和Apple,Apple ≦ Fruit，Fruit类有一个方法fun1，返回一个Object对象:

{% highlight Java %}
public Object fun1() {
            return null;
}
Fruit f = new Fruit();
//某地方用到了f对象
Object obj = f.fun1();
{% endhighlight %}

那么现在Aplle对象覆盖fun1，假设可以返回一个String对象：

{% highlight Java %}
@Override
public String fun1() {
    return "";
}
Fruit f = new Apple();
//某地方用到了f对象
Object obj = f.fun1();
{% endhighlight %}

那么任何使用Fruit对象的地方都能替换成Apple对象吗？显然是可以的。

举得例子是返回值，如果是方法参数呢？调用父类方法fun2(String)的地方肯定可以被一个能够接受更宽类型的方法替代：fun2(Object)......

## 返回值协变和参数逆变
{: #retrun-value-cobariance-and-argument-contravariance}

上面提到的Java和C#语言都没有把函数作为一等公民，那么那些支持一等函数的语言，即把函数也看做一种类型是如何支持协变和逆变的以及里氏原则的呢？

也就是什么时候用一个函数g能够替代其他使用函数f的地方。答案是：

> 函数f可以安全替换函数g，如果与函数g相比，函数f接受更一般的参数类型，返回更特化的结果类型。《维基百科》

这就是是所谓的`对输入类型是逆变的而对输出类型是协变的`[Luca Cardelli提出的规则][2]

虽然Java是面向对象的语言，但某种程度上它仍然遵守这个规则，见上一节的例子，这叫做`返回值协变`，Java子类覆盖父类方法的时候能够返回一个“更窄”的子类型，所以说Java是一门可以支持返回值协变的语言。

类似`参数逆变`是指子类覆盖父类方法时接受一个“更宽”的父类型。在Java和C#中这都被当作了`方法重载`。

能到这又绕糊涂了，返回值协变和参数逆变又是什么东东？回头看看协变和逆变的理解。把方法当成一等公民： 

- 构造类型：Apple ≦ Fruit 
- 返回值：String ≦ Object 
- 参数：Object ≧ String

以上都是我个人对协变和逆变这两个概念的理解（欢迎拍砖）。说个题外话：“概念”是个很抽象的东西，之前听到一个不错说法，说概念这个单词英文叫做`concept`，`con`表示“共同的”，`cept`表示“大脑”。

## Java泛型中的协变和逆变
{: #covariance-and-contravariance-in-java}

一般我们看Java泛型好像是不支持协变或逆变的，比如前面提到的`List<Object>`和`List<String>`之间是不可变的。但当我们在Java泛型中引入通配符这个概念的时候，Java 其实是支持协变和逆变的。

看下面几行代码：

{% highlight Java %}
// 不可变
List<Fruit> fruits = new ArrayList<Apple>();// 编译不通过
// 协变
List<? extends Fruit> wildcardFruits = new ArrayList<Apple>();
// 协变->方法的返回值，对返回类型是协变的:Fruit->Apple
Fruit fruit = wildcardFruits.get(0);
// 不可变
List<Apple> apples = new ArrayList<Fruit>();// 编译不通过
// 逆变
List<? super Apple> wildcardApples = new ArrayList<Fruit>();
// 逆变->方法的参数，对输入类型是逆变的:Apple->Fruit
wildcardApples.add(new Apple());
{% endhighlight %}

可见在Java泛型中通过`extends`关键字可以提供协变的泛型类型转换，通过`supper`可以提供逆变的泛型类型转换。

关于Java泛型中`supper`和`extends`关键字的作用网上有很多文章，这里不再赘述。只举一个《Java Core》里面`supper`使用的例子：下面的代码能够对实现`Comparable`接口的对象数组求最小值。

{% highlight Java %}
public static <T extends Comparable<T>> T min(T[] a) {
    if (a == null || a.length == 0) {
            return null;
    }
    T t = a[0];
    for (int i = 1; i < a.length; i++) {
        if (t.compareTo(a[i]) > 0) {
            t = a[i];
        }
    }
    return t;
}
{% endhighlight %}

这段代码对`Calendar`类是运行正常的，但对`GregorianCalendar`类则无法编译通过：

{% highlight Java %}
Calendar[] calendars = new Calendar[2];
Calendar ret3 = CovariantAndContravariant.<Calendar> min(calendars);
GregorianCalendar[] calendars2 = new GregorianCalendar[2];
GregorianCalendar ret2 = CovariantAndContravariant.<GregorianCalendar> min(calendars2);//编译不通过
{% endhighlight %}

如果想工作正常需要将方法签名修改为： 

	public static <T extends Comparable<? super T>> T min(T[] a)

至于原因，大家看下源码和网上大量关于`supper`的作用应该就明白了，我这里希望能够给看了上面内容的同学提供另外一个思路......

C#虽然不支持泛型类型的协变和逆变(接口和委托是支持的，我之前的那篇博客也提到了),至于为什么C#不支持，《深入解析C#》中说是主要归结于两种语言泛型的实现不同：C#是运行时的，Java只是一个“编译时”特性。但究竟是为什么还是没说明白，希望有时间再研究下。

## 参考资料
{: #see-also}

[维基百科][3]

 [1]: http://jindong.io/2012/04/13/understand-covariance-and-contravariance
 [2]: http://lucacardelli.name/Papers/Inheritance%20%28Semantics%20of%20Data%20Types%29.pdf
 [3]: http://zh.wikipedia.org/wiki/%E5%8D%8F%E5%8F%98%E4%B8%8E%E9%80%86%E5%8F%98