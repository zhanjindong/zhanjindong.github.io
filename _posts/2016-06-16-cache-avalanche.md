---
layout: post
title: "使用HashMap进行本地缓&预防缓存雪崩"
description: "使用HashMap进行本地缓&预防缓存雪崩"
categories: [notes]
tags: [Cache]
alias: [/2016/06/16/]
utilities: fancybox, unveil, highlight
---

高并发下程序首先出现瓶颈的地方往往是I/O，为了追求更高的性能，我们经常把数据加载到本地的内存里进行存取，一般使用的数据结构就是HashMap。
这时有一个问题我们不得不考虑，就是“缓存雪崩”，所谓雪崩就是指当缓存失效的一瞬间，会有大量的请求的落到后端的数据库上面，造成性能问题。

为了解决这个问题，我们在HashMap上面封装了一层，整体思路比较简单：
1. 每个Key维护一个过期时间(atime)和更新时间(uptime)；
2. 当value过期的时候，将uptime更新为当前时间；
3. 线程get数据的时候，首先检查当前的atime有没有过期，如果过期了则将atime加上一个指定“不新鲜”时间段 stale；
4. 发现数据过期的线程去加载最新的数据，其余的线程在 stale 时间段内返回“不新鲜”的老数据，过后就返回最新数据。

为了保证每次缓存更新的时候只会有一个线程去更新数据，其余的线程仍然返回老数据，2和3两个步骤可能需要加锁，加锁带来的锁竞争必然会有性能损失。

代码大致如下：

{% highlight Java %}
public class CacheMapWrapper<K, V> {

	private static Logger LOGGER = LoggerFactory.getLogger(CacheMapWrapper.class);

	private final Map<K, V> data = new ConcurrentHashMap<K, V>();
	private final Map<K, Long> keysatime = new ConcurrentHashMap<K, Long>();
	private final Map<K, Long> keysutime = new ConcurrentHashMap<K, Long>();
	private Lock lock = new ReentrantLock();
	private volatile long atime = System.currentTimeMillis();
	private volatile long utime = -1;
	private long expire = 365 * 24 * 60 * 60 * 1000;// 缓存过期的时间，超过这个时间会主动清空缓存,默认时间很长基本等于不会主动失效。
	private long stale = 5 * 1000;// 缓存更新的时候，并发的线程使用过期数据的最长时间。默认5秒.

	//TODO:JMX
	private AtomicLong totalCount = new AtomicLong(0);
	private AtomicLong missConnt = new AtomicLong(0);

	/**
	 * 
	 * @param expire
	 *            缓存过期的时间，超过这个时间会主动清空缓存.
	 */
	public CacheMapWrapper(long expire) {
		this.expire = expire;
	}

	/**
	 * 
	 * @param expire
	 *            缓存过期的时间，超过这个时间会主动清空缓存.
	 * @param stale
	 *            缓存更新的时候，并发的线程使用过期数据的时间。默认5秒.
	 */
	public CacheMapWrapper(long expire, long stale) {
		this.expire = expire;
		this.stale = stale;
	}

	public CacheMapWrapper() {
	}

	public Map<K, V> getAll() {
		long now = System.currentTimeMillis();

		boolean flag = false;
		lock.lock();
		try {
			if (((atime + stale) < now) || (atime < utime)) {
				atime = now + stale;
				flag = true;
			}
		} finally {
			lock.unlock();
		}

		if (flag) {
			LOGGER.warn(Thread.currentThread().getId() + " going to flush the cache map.");
			return null;
		}

		return data;
	}

	public void setAll(Map<K, V> newMap) {
		data.clear();
		data.putAll(newMap);
		long now = System.currentTimeMillis();
		atime = now;
		utime = now;
	}

	public V get(K key) {
		V value = data.get(key);
		if (value == null) {
			return null;
		}

		long now = System.currentTimeMillis();
		boolean flag = false;
		lock.lock();
		try {
			Long katime = keysatime.get(key);
			Long kutime = keysutime.get(key);
			if (katime == null || kutime == null) {
				flag = true;
			} else if (katime < kutime || atime < utime || (katime + expire) < now || (atime + expire) < now) {
				atime = katime = now + stale;// delay 5 seconds
				keysatime.put(key, katime);
				flag = true;
			}
		} finally {
			lock.unlock();
		}

		totalCount.addAndGet(1);
		if (flag) {
			missConnt.addAndGet(1);
			LOGGER.warn(Thread.currentThread().getName() + " going to flush the cache key.");
			return null;
		}

		return value;
	}

	public void put(K key, V value) {
		data.put(key, value);
		long now = System.currentTimeMillis();
		keysatime.put(key, now);
		keysutime.put(key, now);
	}

	public void remove(K key) {
		lock.lock();
		try {
			keysutime.put(key, System.currentTimeMillis());
		} finally {
			lock.unlock();
		}
	}

	public void update() {
		lock.lock();
		try {
			utime = System.currentTimeMillis();
		} finally {
			lock.unlock();
		}

	}

	public void clear() {
		LOGGER.warn(Thread.currentThread().getName() + " clear the cache.");
		update();
	}
}
{% endhighlight %}

## 防雪崩的效果

### 使用ConcurrentHashMap

<a class="post-image" href="/assets/images/posts/concurrent-hashmap.png">
<img itemprop="image" data-src="/assets/images/posts/concurrent-hashmap.png" src="/assets/js/unveil/loader.gif" alt="concurrent-hashmap.png" />
</a>

### 使用CacheMapWrapper

<a class="post-image" href="/assets/images/posts/cachemapwrapper.png">
<img itemprop="image" data-src="/assets/images/posts/cachemapwrapper.png" src="/assets/js/unveil/loader.gif" alt="cachemapwrapper.png" />
</a>


## 性能测试（真实业务场景）：

### 使用ConcurrentHashMap

<a class="post-image" href="/assets/images/posts/concurrenthashmap-cpu.png">
<img itemprop="image" data-src="/assets/images/posts/concurrenthashmap-cpu.png" src="/assets/js/unveil/loader.gif" alt="concurrenthashmap-cpu.png" />
</a>


<a class="post-image" href="/assets/images/posts/concurrenthashmap-tps.png">
<img itemprop="image" data-src="/assets/images/posts/concurrenthashmap-tps.png" src="/assets/js/unveil/loader.gif" alt="concurrenthashmap-tps.png" />
</a>

### 使用CacheMapWrapper ReentrantLock

<a class="post-image" href="/assets/images/posts/cachemap-cpu.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap-cpu.png" src="/assets/js/unveil/loader.gif" alt="cachemap-cpu.png" />
</a>

<a class="post-image" href="/assets/images/posts/cachemap-cpu2.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap-cpu2.png" src="/assets/js/unveil/loader.gif" alt="cachemap-cpu2.png" />
</a>


<a class="post-image" href="/assets/images/posts/cachemap-tps.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap-tps.png" src="/assets/js/unveil/loader.gif" alt="cachemap-tps.png" />
</a>

可以看到高并发下锁竞争带来的性能损失不容忽视，TPS少了20%以上。


### 使用CacheMapWrapper 将ReentrantLock换成ReadWriteReentrantLock读写锁


<a class="post-image" href="/assets/images/posts/concurrenthashmap-tps.png">
<img itemprop="image" data-src="/assets/images/posts/concurrenthashmap-tps.png" src="/assets/js/unveil/loader.gif" alt="concurrenthashmap-tps.png" />
</a>


<a class="post-image" href="/assets/images/posts/cachemap2-cpu.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap2-cpu.png" src="/assets/js/unveil/loader.gif" alt="cachemap2-cpu.png" />
</a>

<a class="post-image" href="/assets/images/posts/cachemap2-cpu2.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap2-cpu2.png" src="/assets/js/unveil/loader.gif" alt="cachemap2-cpu2.png" />
</a>


<a class="post-image" href="/assets/images/posts/cachemap2-tps.png">
<img itemprop="image" data-src="/assets/images/posts/cachemap2-tps.png" src="/assets/js/unveil/loader.gif" alt="cachemap2-tps.png" />
</a>

可以看到CPU利用率TPS跟直接用ConcurrentHashMap持平。





