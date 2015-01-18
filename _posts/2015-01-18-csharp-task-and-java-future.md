---
layout: post
title: "C#的Task和Java的Future"
description: "C#的Task和Java的Future"
categories: [articles]
tags: [C#,Java]
alias: [/2014/03/08/]
---

自从项目中语言换成Java后就很久没有看C#了，但说实话我是身在曹营心在汉啊。早就知道.NET4.5新增了`async`和`await`但一直没有用过，今天看到[这篇文章][1]总算有了点了解，突然发现`Task`这个玩意不就是Java中`Future`这个概念吗？

这里冒昧引用下[Jesse Liu][2]文中的C#代码：

{% highlight c# %}
static void Main(string[] args)
        {

            Console.WriteLine("Main Thread Id: {0}\r\n", Thread.CurrentThread.ManagedThreadId);
            Test();
            Console.ReadLine();
            
        }

        static async Task Test()
        {
            Console.WriteLine("Before calling GetName, Thread Id: {0}\r\n", Thread.CurrentThread.ManagedThreadId);
            var name = GetName();   
            Console.WriteLine("End calling GetName.\r\n");
            Console.WriteLine("Get result from GetName: {0}", await name);
        }


        static async Task<string> GetName()
        {
            // 这里还是主线程
            Console.WriteLine("Before calling Task.Run, current thread Id is: {0}", Thread.CurrentThread.ManagedThreadId);
            return await Task.Run(() =>
            {
                Thread.Sleep(5000);
                Console.WriteLine("'GetName' Thread Id: {0}", Thread.CurrentThread.ManagedThreadId);
                return "zhanjindong";
            });
        }
{% endhighlight %}

大家看下"等价"的Java代码是不是“一模一样”？

{% highlight java %}
static ExecutorService service = Executors.newFixedThreadPool(10);
	/**
	 * @param args
	 * @throws ExecutionException 
	 * @throws InterruptedException 
	 */
	public static void main(String[] args) throws InterruptedException, ExecutionException {
		
		System.out.println("Main Thread Id: " + Thread.currentThread().getId());
		test();
	}
	
	static void test() throws InterruptedException, ExecutionException{
		
		System.out.println("Before calling getName, Thread Id: "+Thread.currentThread().getId());		
		Future<String> name = getName();		
		System.out.println("End calling getName.");
		System.out.println("Get result from getName: " + name.get());
		
	}
	
	static Future<String> getName(){
		
		System.out.println("Before calling ExecutorService.submit, current thread Id is: "+Thread.currentThread().getId());
		
		return service.submit(new Callable<String>() {

			@Override
			public String call() throws Exception {

				Thread.sleep(5000);
				System.out.println("'getName' Thread Id: "+Thread.currentThread().getId());
				return "zhanjindong";
			}

		});
	}
{% endhighlight %}

当然上面的代码为了说明都冗余了点，输出的结果自然也是一样的：

![此处输入图片的描述][3]
![此处输入图片的描述][4]

说“等价”是因为无论是Task还是Future都是为了对异步操作进行封装，Java中`Future.get`相当于C#中的`Task.Result`。`await name`不过是一个语法糖而已（但这语法糖很重要，async和await能让我们以写同步代码的方式实现异步的逻辑）。做一件正确的事的思路往往是一样的，但是实现的细节总是有差别。这次我倒似乎更喜欢Java中Future这个名词，直观明了。但C#还是一如既往的讳莫如深（[不过已经进步很大了][5]），这一点也是经常遭业界同仁所诟病，还好我有IL：

![此处输入图片的描述][6]

咦？状态机让我立马想到了[yield return][7]，怪不得我觉得`await`和`yield return`有点神似呢。这也许就是我更喜欢C#的原因：设计上的**一致性**。

简单写点，有时间还是想深入深入啊。


  [1]: http://www.cnblogs.com/jesse2013/p/3560999.html#
  [2]: http://www.cnblogs.com/jesse2013/p/3560999.html#parameters
  [3]: http://zhanjindong.info/wp-content/uploads/2014/03/c-result.png
  [4]: http://zhanjindong.info/wp-content/uploads/2014/03/Java-result.png
  [5]: http://referencesource.microsoft.com/
  [6]: http://zhanjindong.info/wp-content/uploads/2014/03/state-machine.png
  [7]: http://zhanjindong.info/2013/09/01/%E5%8F%AF%E6%83%9Cjava%E4%B8%AD%E6%B2%A1%E6%9C%89yield-return/
  [8]: http://zhanjindong.info/2014/03/08/charp-task-and-java-future/