---
layout: post
title: "一道Twitter面试题"
description: "一道Twitter面试题"
categories: [notes]
tags: [leetcode]
alias: [/2015/02/06/]
utilities: fancybox,unveil,highlight
---

在微博上看到的这个[问题][1]，忍住没看答案自己解决了。建议没看过的同学也自己先尝试下。

## 问题
{: #question}

“看下面这个图片”

<a class="post-image" href="/assets/images/posts/4eb24f295ccf64c86c28b0e4fc59d83b.jpg">
<img itemprop="image" data-src="/assets/images/posts/4eb24f295ccf64c86c28b0e4fc59d83b.jpg" src="/assets/js/unveil/loader.gif" alt="4eb24f295ccf64c86c28b0e4fc59d83b.jpg" />
</a>

在这个图片里我们有不同高度的墙。这个图片由一个整数数组所代表，数组中每个数是墙的高度。上边的图可以表示为数组[2,5,1,2,3,4,7,7,6]”
“假如开始下雨了，那么墙之间的水坑能够装多少水呢？”

比如上面这个图的的答案应该就是10:

<a class="post-image" href="/assets/images/posts/7cc829d3gw1ea56pjntkoj205m03zaa2.jpg">
<img itemprop="image" data-src="/assets/images/posts/7cc829d3gw1ea56pjntkoj205m03zaa2.jpg" src="/assets/js/unveil/loader.gif" alt="7cc829d3gw1ea56pjntkoj205m03zaa2.jpg" />
</a>

**思考时间**

<a class="post-image" href="/assets/images/posts/c-girl.png">
<img itemprop="image" data-src="/assets/images/posts/c-girl.png" src="/assets/js/unveil/loader.gif" alt="c-girl.png" />
</a>


## 提示
{: #prompt}

先找到最大值，然后从左右分别遍历，这需要两次遍历，也可以一次遍历就搞定，类似快排那样需要两个指针。

**思考时间**

<a class="post-image" href="/assets/images/posts/c-girl.png">
<img itemprop="image" data-src="/assets/images/posts/c-girl.png" src="/assets/js/unveil/loader.gif" alt="c-girl.png" />
</a>

## 答案(Java)
{: #solution}


{% highlight Java %}
public class TwitterPuddle {

	@Test(dataProvider = "testCase")
	public void test(int[] c, int expected) {
		Assert.assertEquals(calc(c), expected);
		Assert.assertEquals(calc2(c), expected);
	}

	@DataProvider(name = "testCase")
	public Object[][] testCase() {
		return new Object[][] { 
				{ new int[] { 2, 5, 1, 3, 1, 2, 1, 7, 7, 6 }, 17 },
				{ new int[] { 2, 5, 1, 2, 3, 4, 7, 7, 6 }, 10 },
				{ new int[] { 2, 1, 2 }, 1 },
				{ new int[] { 1, 2, 3, 4, 5, 6 }, 0 } };
	}

	// 需要2次遍历数组
	private static int calc(int[] walls) {
		// 先找到最高的一堵墙
		int maxi = 0;
		for (int i = 1; i < walls.length; i++) {
			if (walls[i] > walls[maxi]) {
				maxi = i;
			}
		}

		// 从左往右遍历
		int water = 0;
		int higher = walls[0];
		for (int i = 1; i < maxi; i++) {
			if (walls[i] < higher) {// 没遇到更高的墙则水可以一直升到当前位置
				water += higher - walls[i];
			} else {// 否则多出的都会从左边流掉
				higher = walls[i];
			}
		}
		// 从右往左遍历
		higher = walls[walls.length - 1];
		for (int i = walls.length - 2; i > maxi; i--) {
			if (walls[i] < higher) {
				water += higher - walls[i];
			} else {
				higher = walls[i];
			}
		}
		return water;
	}

	// 1次遍历:从左右向中间逼近。
	private static int calc2(int[] walls) {
		int water = 0;
		int lhigher = walls[0];
		int rhigher = walls[walls.length - 1];
		int i = 0, j = walls.length - 1;
		while (i != j) {
			if (walls[i] < walls[j]) {
				if (walls[i] < lhigher) {
					water += lhigher - walls[i];
				} else {
					lhigher = walls[i];
				}
				i++;
			} else {
				if (walls[j] < rhigher) {
					water += rhigher - walls[j];
				} else {
					rhigher = walls[j];
				}
				j--;
			}
		}
		return water;
	}
}

{% endhighlight %}


测了几个用例应该是对的，但是实现方法不一定是最好的。



 [1]: http://ask.julyedu.com/question/140