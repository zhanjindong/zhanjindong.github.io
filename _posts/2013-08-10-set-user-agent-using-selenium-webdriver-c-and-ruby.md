---
layout: post
title: "使用 Selenium WebDriver C# 和 Ruby 给浏览器设置 User Agent"
description: "如何使用 Selenium WebDriver C# 和 Ruby 来设置浏览器（Chrome, Firefox, IE, PhantomJS）的 user agent。"
categories: [articles, popular]
tags: [c#, ruby, selenium-webdriver]
alias: [/2013/08/10/]
utilities: highlight
---
本文将展示如何使用 Selenium WebDriver C# and Ruby 给 Chrome，Firefox，IE，PhantomJS 浏览器设置 User Agent 的方法。

> 环境:<br />
> Linux Mint 16, Ruby 2.1.1p76, Selenium 2.41.0, ChromDriver 2.9<br/>
> Firefox 28.0, Chrome 33, PhantomJS 1.9.7
>
> User Agent 示例（ipad）:<br />
> Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10

* Kramdown table of contents
{:toc .toc}

## Chrome
{: #chrome}

### C&#35;
{: #chrome-c-sharp}

{% prettify c# %}
var options = new ChromeOptions();
options.AddArgument("--user-agent=Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25");

IWebDriver driver = new ChromeDriver(options);
{% endprettify %}

### Ruby
{: #chrome-ruby}

{% highlight ruby %}
require 'selenium-webdriver'

USER_AGENT = 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10;'
driver = Selenium::WebDriver.for :chrome, :switches => %W[--user-agent=#{USER_AGENT}]
{% endhighlight %}

## Firefox
{: #firefox}

### C&#35;
{: #firefox-c-sharp}

{% prettify c# %}
var profile = new FirefoxProfile();
profile.SetPreference("general.useragent.override", "Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10");

IWebDriver driver = new FirefoxDriver(profile);
{% endprettify %}

### Ruby
{: #firefox-ruby}

{% highlight ruby %}
require 'selenium-webdriver'

profile = Selenium::WebDriver::Firefox::Profile.new
profile['general.useragent.override'] = 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10'

driver = Selenium::WebDriver.for :firefox, :profile => profile
{% endhighlight %}

## PhantomJS
{: #phantomjs}

### C&#35;
{: #phantomjs-c-sharp}

{% prettify c# %}
var options = new PhantomJSOptions();
options.AddAdditionalCapability("phantomjs.page.settings.userAgent", "Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10");

IWebDriver driver = new PhantomJSDriver(options);
{% endprettify %}

### Ruby
{: #phantomjs-ruby}

{% highlight ruby %}
require 'selenium-webdriver'

capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs('phantomjs.page.settings.userAgent' => 'Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10')

driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
{% endhighlight %}

## IE
{: #ie}

不幸但不出意料，IE 不允许 Selenium WebDriver 来原生地设置 User Agent。
以下[引用][Set IEDriver UA]自 IE driver 的开发者 Jim Evans：

> The IE driver does not support changing the user agent, using capabilities or otherwise. Full stop.

[Set IEDriver UA]: https://groups.google.com/d/msg/selenium-users/q1f-nIn1BJY/pjnmCc3jSz4J

