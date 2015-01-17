---
layout: post
title: "在 Travis CI 上创建 Selenium WebDriver Ruby 项目"
description: "如何在 Travis CI 上创建一个使用 headless PhantomJS 浏览器的 Selenium WebDriver Ruby 自动化测试项目。"
categories: [articles, popular]
tags: [github, phantomjs, ruby, selenium-webdriver, travis-ci]
alias: [/2013/06/15/]
utilities: fancybox, highlight, unveil
---
> 原文已于2014年4月20日更新，请点击[本链接](http://yizeng.me/2013/06/15/setup-a-selenium-webdriver-ruby-project-on-travis-ci/)查看最新版本

* Kramdown table of contents
{:toc .toc}

## 在 Github 上创建一个代码仓库
{: #create-repo}

要想在 Travis CI 上运行项目，必须首先要在 Github 上创建一个代码仓库。
如果还没有建立代码仓库，请前往 Github 的 ['Create a New Repository'](https://github.com/repositories/new) 页面创建一个新的公开代码仓库。

## 建立 Selenium WebDriver Ruby 项目
{: #create-project}

### 项目结构
{: #project-structure}

以下是本示例 Selenium Ruby 项目的结构：

	/root                       -- 代码的根目录
	    /test                   -- 示例测试的文件夹
	        test_home_page.rb   -- 示例测试文件
	    .travis.yml             -- Travis CI 的配置文件
	    README.md               -- 项目简介
	    Rakefile                -- Rakefile

### 编写一个使用 headless PhantomJS 的 UI 测试
{: #create-sample-test}

- `Test::Unit` 是本示例所使用的测试框架。
- Headless WebKit [PhantomJS](http://phantomjs.org/) 是本示例将要测试的浏览器。
- PhantomJS 的可执行文件应该已经被预案装于 [Travis CI 服务器](http://about.travis-ci.org/docs/user/ci-environment/)上，
目前于 05/07/2013 时的版本为 `1.9.1`
- Travis CI 同时也支持需要运行 GUI 的测试, 请查阅[文档](http://about.travis-ci.org/docs/user/gui-and-headless-browsers)。

以下为一个示例测试文件叫做 `test_home_page.rb`：
{% highlight ruby %}
require 'selenium-webdriver'
require 'test/unit'

module Test
  class TestHomePage < Test::Unit::TestCase

    def setup
      @driver = Selenium::WebDriver.for :phantomjs
      @driver.navigate.to('http://yizeng.me')
    end

    def teardown
      @driver.quit
    end

    def test_home_page_title
      assert_equal('Yi Zeng', @driver.title)
    end
  end
end
{% endhighlight %}

### 添加 Rakefile
{: #add-rakefile}

Travis CI 使用 `Rakefile` 来编译项目并运行测试，如果该文件不存在，编译会像如下一样报错：

	$ rake
	rake aborted!
	No Rakefile found (looking for: rakefile, Rakefile, rakefile.rb, Rakefile.rb)
	The command "rake" exited with 1.

以下为 Rakefile 示例：
{% highlight ruby %}
require 'rake/testtask'

task :default => [:test]
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'

  # ensure the sample test file is included here
  test.test_files = FileList['test/test_*.rb']

  test.verbose = true
end
{% endhighlight %}

### 添加 .travis.yml
{: #add-travis-yml}

Travis CI 使用在项目根目录下的 `.travis.yml` 来了解项目配置，例如：

- 项目所使用的编程语言
- 运行项目的 setup 和 cleanup
- 运行项目所需要的命令

因为示例项目是写于 Ruby 的，故 Ruby 的配置将被使用于 `.travis.yml` 中。
详细的官方文档可以[在这里](http://about.travis-ci.org/docs/user/languages/ruby/)被查阅。
想要验证配置文件，[Travis Lint](http://about.travis-ci.org/docs/user/travis-lint/) 会是一个非常方便的工具，不过最简单的方法是前往 [Travis WebLint](http://lint.travis-ci.org/) 页面，直接粘贴进配置文件内容。

{% highlight yaml %}
# 示例 .travis.yml 文件:
language: ruby

rvm: # 将被使用的 Ruby 版本
  - 2.0.0
  - 1.9.3
  - 1.9.2

before_install:
  - gem update # 可选，更新所有的 gems
  - gem install selenium-webdriver
  - phantomjs --version # 输出 phantomjs 版本
{% endhighlight %}

## 上传至 Github
{: #push-to-github}

一旦代码仓库已正确设立了，就可以上传至 Github。

## 登入 Travis CI 并开启 hook
{: #enable-hook}

1. 使用本项目的 Github 帐号登入 Travis CI
2. 前往 [Travis CI profile](https://travis-ci.org/profile) 页面并找到此项目的代码仓库，
如果此项目不在列表中，请确认：
	- 此代码仓库不是私有的
	- Travis CI 已经与 Github 同步 （如果需要可以点击 “立即同步” 按钮）
3. 开启此代码仓库的 hook

<a class="post-image" href="/assets/images/posts/2013-06-09-enable-hook-on-travis-ci.gif" title="在 Travis CI 上开启 hook">
  <img itemprop="image" data-src="/assets/images/posts/2013-06-09-enable-hook-on-travis-ci.gif" src="/assets/js/unveil/loader.gif" alt="在 Travis CI 上开启 hook" />
</a>

## 在 Travis CI 上运行项目
{: #run-project}

只要有更新上传至代码仓库，Travis CI 应该会自动运行项目。

不仅如此，若想要手动运行项目，可以通过以下几步：

1. 前往 Github 上项目的设置页面
2. 点选 tab `Service Hooks` (url: https://github.com/[GITHUB_USERNAME]/[REPO_NAME]/settings/hooks)
3. 在列表中下部找到 `Travis`
4. 点 `Test Hook` 按钮

## 在 Travis CI 上分析结果
{: #analyze-results}

### Travis CI 上的项目页面
{: #results-page}

Travis CI 上的项目页面在 `https://travis-ci.org/[GITHUB_USERNAME]/[REPO_NAME]`

<a class="post-image" href="/assets/images/posts/2013-06-15-results-page-on-travis-ci.gif" title="Travis CI 的运行结果页面">
  <img itemprop="image" data-src="/assets/images/posts/2013-06-15-results-page-on-travis-ci.gif" src="/assets/js/unveil/loader.gif" alt="Travis CI 的运行结果页面" />
</a>

### 运行日志
{: #build-log}

点击每个运行序号将会打开该次运行的的日志，里面基本包括所有在运行过程中的控制台输出内容。

### 测试结果
{: #test-results}

测试结果显示在运行日志中的 `rake` 部分。
例如，下面为[此次运行的日志里的测试结果](https://travis-ci.org/yizeng/setup-selenium-webdriver-ruby-project-on-travis-ci/jobs/8109067):

	$ rake
	/home/travis/.rvm/rubies/ruby-2.0.0-p0/bin/ruby -I"lib:test" -I"/home/travis/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib" "/home/travis/.rvm/gems/ruby-2.0.0-p0/gems/rake-10.0.4/lib/rake/rake_test_loader.rb" "test/test_home_page.rb" 
	Run options:

	# Running tests:

	Finished tests in 1.078374s, 0.9273 tests/s, 0.9273 assertions/s.
	1 tests, 1 assertions, 0 failures, 0 errors, 0 skips

	ruby -v: ruby 2.0.0p0 (2013-02-24 revision 39474) [x86_64-linux]
	The command "rake" exited with 0.

### 项目状态图标
{: #build-status-images}

Travis CI 为项目提供了 [项目状态图标](http://about.travis-ci.org/docs/user/status-images/)，
它们作为项目开发的好习惯，被鼓励用于项目主页或 README 文件中。

项目状态图标储存在 `https://travis-ci.org/[GITHUB_USERNAME]/[REPO_NAME].png`，
branches 可以通过如 `?branch=master,staging,production` 的 URL query 字符串来额外添加。

除此之外，在 Travis CI 上的项目主页，点击设置按钮，然后选择 `Status Image`，
一个对话框将会显示全部可能的选项，如下图所示：

<a class="post-image" href="/assets/images/posts/2013-07-05-travis-ci-status-image-options.gif" title="Travis CI 项目状态图标选项">
  <img itemprop="image" data-src="/assets/images/posts/2013-07-05-travis-ci-status-image-options.gif" src="/assets/js/unveil/loader.gif" alt="Travis CI 项目状态图标选项" />
</a>

目前本示例项目的运行状态为： <a class="image-link" href="https://travis-ci.org/yizeng/setup-selenium-webdriver-ruby-project-on-travis-ci" title="Travis CI 项目状态"><img src="https://travis-ci.org/yizeng/setup-selenium-webdriver-ruby-project-on-travis-ci.png" alt="Travis CI 项目状态" /></a>
