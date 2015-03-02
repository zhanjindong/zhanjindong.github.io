---
layout: post
title: "GCC编译pthread代码需要跟-pthread选项"
description: "GCC编译pthread代码需要跟-pthread选项"
categories: [notes]
tags: [Questions,Algorithm]
alias: [/2015/03/02/]
utilities: fancybox,unveil,highlight
---

今天在CentOS上用CodeBlocks写了个简单pthread的代码：

{% highlight cpp %}
#include <pthread.h>
void *thread(void *vargp);

int main(int argc, char **argv)
{
    pthread_t tid;
    pthread_create(&tid,NULL,thread,NULL);
    pthread_join(tid,NULL);
    exit(0);
}

void *thread(void *vargp)
{
    printf("Hello,world!\n");
    return NULL;
}
{% endhighlight %}

但是死活编译不了，总是报`undefined reference to pthread_create`这个错误。最后还是在tackexchange上找到了[答案][1]
原来最新版本的`gcc`需要跟`-pthread`这个参数：

	gcc -pthread hello.c -o hello

这样就可以了，CodeBlocks设置：

Settings → Compiler → Linker settings → Other link options

另外如果用CodeBlocks需要手动的添加链接文件，不然也会报类似的错误。

<a class="post-image" href="/assets/images/posts/code-blocks-build-target.png">
<img itemprop="image" data-src="/assets/images/posts/code-blocks-build-target.png" src="/assets/js/unveil/loader.gif" alt="code-blocks-build-target.png" />
</a>

记录一下。


[1]: http://unix.stackexchange.com/questions/33396/gcc-cant-link-to-pthread

