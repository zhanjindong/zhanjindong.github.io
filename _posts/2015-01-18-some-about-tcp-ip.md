---
layout: post
title: "TCP&IP相关"
description: "TCP&IP相关"
categories: [notes]
tags: [TCP&IP]
alias: [/2015/01/18/]
---

```
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
        static async Task GetName()
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
```