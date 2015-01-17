---
layout: post
title: "在 Windows 上安装 Jekyll"
description: "如何在 Windows 上安装 Jekyll"
categories: [notes, popular]
tags: [jekyll, ruby, windows]
alias: [/2013/05/10/]
last_updated: April 20, 2014
utilities: fancybox, unveil
---
> 若想查看原文，请点击[本链接](http://yizeng.me/2013/05/10/setup-jekyll-on-windows/)。

* Kramdown table of contents
{:toc .toc}

## 安装 Ruby
{: #install-ruby}

1. 前往 <http://rubyinstaller.org/downloads/>

2. 在 "RubyInstallers" 部分，选择某个版本点击下载。<br />
   例如， Ruby 2.0.0-p451 (x64) 是适于64位 Windows 机器上的 Ruby 2.0.0 x64 安装包。

3. 通过安装包安装

	- 最好保持默认的路径 `C:\Ruby200-x64`，
	  因为安装包明确提出 “请不要使用带有空格的文件夹 (如： Program Files)”。
	- 勾选 "Add Ruby executables to your PATH"，这样执行程序会被自动添加至 PATH 而避免不必要的头疼。

	<a class="post-image" href="/assets/images/posts/2013-05-11-ruby-installer.png">
	<img itemprop="image" data-src="/assets/images/posts/2013-05-11-ruby-installer.png" src="/assets/js/unveil/loader.gif" alt="Windows Ruby 安装包" />
	</a>

4. 打开一个命令提示行并输入以下命令来检测 Ruby 是否成功安装。

	> ruby -v

	输出示例：

	> ruby 2.0.0p451 (2014-02-24) [x64-mingw32]

## 安装 DevKit
{: #install-devkit}

DevKit 是一个在 Windows 上帮助简化安装及使用 Ruby C/C++ 扩展如 RDiscount 和 RedCloth 的工具箱。
详细的安装指南可以在程序的 [wiki 页面][Full installation instructions] 阅读。

1. 再次前往 <http://rubyinstaller.org/downloads/>

2. 下载同系统及 Ruby 版本相对应的 DevKit 安装包。
   例如，DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe 适用于64位 Windows 系统上的 Ruby 2.0.0 x64。

	下面列出了如何选择正确的 DevKit 版本：

	> **Ruby 1.8.6 to 1.9.3**: DevKit tdm-32-4.5.2<br />
	> **Ruby 2.0.0**: DevKit mingw64-32-4.7.2<br />
	> **Ruby 2.0.0 x64**: DevKit mingw64-64-4.7.2

3. 运行安装包并解压缩至某文件夹，如 C:\DevKit

4. 通过初始化来创建 config.yml 文件。在命令行窗口内，输入下列命令：

	> cd "C:\DevKit"<br />
	> ruby dk.rb init<br />
	> notepad config.yml

5. 在打开的记事本窗口中，于末尾添加新的一行 `- C:\Ruby200-x64`，保存文件并退出。

6. 回到命令行窗口内，审查（非必须）并安装。

	> ruby dk.rb review<br />
	> ruby dk.rb install

## 安装 Jekyll
{: #install-jekyll}

1. 确保 gem 已经正确安装

	> gem -v

	输出示例：

	> 2.0.14

2. 安装 Jekyll gem

	> gem install jekyll

## 安装 Pygments
{: #install-pygements}

Jekyll 里默认的语法高亮插件是 [Pygments](http://pygments.org/)。
它需要安装 Python 并在网站的配置文件 `_config.yml` 里将 `highlighter` 的值设置为 `pygments`。

不久之前，Jekyll 还添加另一个高亮引擎名为 [Rouge](https://github.com/jayferd/rouge)，
尽管暂时不如 Pygments 支持那么多的语言，但它是原生 Ruby 程序，而不需要使用 Python。
更多信息请[点此](http://jekyllrb.com/docs/templates/#code_snippet_highlighting)关注。

### 安装 Python
{: #install-python}

1. 前往 <http://www.python.org/download/>
2. 下载合适的 Python windows 安装包，如 Python 2.7.6 Windows Installer。 请注意，Python 2 可能会更合适，因为暂时 Python 3 可能不会正常工作。
3. 安装
4. 添加安装路径 (如： C:\Python27) 至 PATH。(如何操作? 请参见 [故障诊断 #1](#troubleshooting))
5. 检验 Python 安装是否成功

	> python --version

	输出示例：

	> Python 2.7.6

### 安装 'Easy Install'
{: #install-easy-install}

1. 浏览 <https://pypi.python.org/pypi/setuptools#installation-instructions> 来查看详细的安装指南。
2. 对于 Windows 7 的机器，下载 [ez_setup.py](https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py) 并保存，例如，至`C:\`。
   然后从命令行使用 Python 运行此文件：

	> python "C:\ez_setup.py"

3. 添加 'Python Scripts' 路径 (如： C:\Python27\Scripts) 至 PATH

### 安装 Pygments
{: #install-pygements-2}

1. 确保 easy_install 已经正确安装

	> easy_install --version

	输出示例：

	> setuptools 3.1

2. 使用 "easy_install" 来安装 Pygments

	> easy_install Pygments

## 启动 Jekyll
{: #start-jekyll}

按照官方的 [Jekyll 快速开始手册][Jekyll Quick-start guide]
的步骤， 一个新的 Jekyll 博客可以被建立并在 [localhost:4000](http://localhost:4000)浏览。

> jekyll new myblog<br />
> cd myblog<br />
> jekyll serve

## 故障诊断
{: #troubleshooting}

1. 错误信息：

	   “python” is not recognized as an internal or external command, operable program or batch file.

	**其他情况**： 这里的 "python" 也可能是 "ruby"， "gem" 或是 "easy_install" 等。

	**可能原因**： 该程序可能未被正确地安装或未在 PATH 里设置成功。

	**尝试解法**： 确保程序已被正确安装。然后手动将其添加至 PATH，请参考如下步骤{% footnote 1 %}。

	> 1. 按住 Win 键再按下 Pause
	> 2. 点击 Advanced System Settings
	> 3. 点击 Environment Variables
	> 4. 将 ;C:\python27 添加至 Path 变量的末尾
	> 5. 重启命令行

2. 错误信息：

	   ERROR:  Error installing jekyll:
	   ERROR: Failed to build gem native extension.

	   "C:/Program Files/Ruby/Ruby200-x64/bin/ruby.exe" extconf.rb

	   creating Makefile
	   make generating stemmer-x64-mingw32.def
	   compiling porter.c
	   ...
	   make install
	   /usr/bin/install -c -m 0755 stemmer.so C:/Program Files/Ruby/Ruby200-x64/lib/ruby/gems/2.0.0/gems/fast-stemmer-1.0.2/li
	   /usr/bin/install: target `Files/Ruby/Ruby200-x64/lib/ruby/gems/2.0.0/gems/fast-stemmer-1.0.2/lib' is not a directory
	   make: *** [install-so] Error 1

	**可能原因**： Ruby 被安装在含有空格的路径里。

	**尝试解法**： 重新安装 Ruby，这次请不要使用带有空格的路径，或者请直接选择使用默认路径。

3. 错误信息：

	   Generating... Liquid Exception: No such file or directory - python c:/Ruby200-x64/lib/ruby/gems/2.0.0/gems/pygments.rb-0.4.2/lib/pygments/mentos.py in 2013-04-22-yizeng-hello-world.md

	**可能原因**： Pygments 未能被正确安装或是 PATH 设置尚未生效。

	**尝试解法**： 首先请确保 Pygments 已成功安装且 Python 的 PATH 设置正确未包含空格和最后多余的斜杠。
    然后重启命令行。如果依旧失败，请尝试注销并重新登录 Windows。
    甚至使用终极解法，重启电脑。

4. 错误信息：

	   Generating... Liquid Exception: No such file or directory - /bin/sh in _posts/2013-04-22-yizeng-hello-world.md

	**可能原因**： 与 pygments.rb 0.5.1/0.5.2 版本的兼容性问题。

	**尝试解法**： 将 pygments.rb gem 的版本从 0.5.1/0.5.2 降至 0.5.0。

	> gem uninstall pygments.rb --version '=0.5.2'<br />
	> gem install pygments.rb --version 0.5.0

5. 错误信息：

	   c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/dependency.rb:296:in `to_specs': Could not find 'pygments.rb' (~> 0.4.2) - did find: [pygments.rb-0.5.0] (Gem::LoadError)
	   from c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/specification.rb:1196:in `block in activate_dependencies'
	   from c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/specification.rb:1185:in `each'
	   from c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/specification.rb:1185:in `activate_dependencies'
	   from c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/specification.rb:1167:in `activate'
	   from c:/Ruby200-x64/lib/ruby/2.0.0/rubygems/core_ext/kernel_gem.rb:48:in`gem'
	   from c:/Ruby200-x64/bin/jekyll:22:in `<main>'`

	**可能原因**：如错误信息所述，找不到 pygments.rb 0.4.2，仅找到 pygments.rb 0.5.0。 （此问题出现于此文初稿时的 Jekyll 版本，现版本应已修复）

	**尝试解法**： 将 pygments.rb gem 的版本降级至 0.4.2

	> gem uninstall pygments.rb --version “=0.5.0”<br />
	> gem install pygments.rb --version “=0.4.2”

6. 错误信息：

	   Generating... You are missing a library required for Markdown. Please run:
	   $ [sudo] gem install rdiscount
	   Conversion error: There was an error converting '_posts/2013-04-22-yizeng-hello-world.md/#excerpt'.

	   ERROR: YOUR SITE COULD NOT BE BUILT:
	      ------------------------------------
	      Missing dependency: rdiscount

	**可能原因**： 依赖包 `rdiscount` 未找到。
	此问题最有可能的原因是，网站使用的是 [rdiscount](https://github.com/davidfstr/RDiscount) 作为 Markdown 引擎，而不是 Jekyll 默认的引擎，故需要手动自行安装。

	**尝试解法**：

	> gem install rdiscount

7. 错误信息：

	   c:/Ruby200-x64/lib/ruby/site_ruby/2.0.0/rubygems/core_ext/kernel_require.rb:55:in `require': cannot load such file -- wdm (LoadError)
	   from c:/Ruby200-x64/lib/ruby/site_ruby/2.0.0/rubygems/core_ext/kernel_require.rb:55:in `require'
	   from c:/Ruby200-x64/lib/ruby/gems/2.0.0/gems/listen-1.3.1/lib/listen/adapter.rb:207:in `load_dependent_adapter'
	   from c:/Ruby200-x64/lib/ruby/gems/2.0.0/gems/listen-1.3.1/lib/listen/adapters/windows.rb:33:in `load_dependent_a
	   dapter'
	   ...

	**可能原因**： `wdm` gem 未被安装。因为 Jekyll 只官方地支持 *nix 系统，所以 [Windows Directory Monitor][WDM] 并没有作为依赖包而被自动安装。

	**尝试解法**：

	> gem install wdm

[Full installation instructions]: https://github.com/oneclick/rubyinstaller/wiki/Development-Kit#installation-instructions
[Jekyll Quick-start guide]: http://jekyllrb.com/docs/quickstart/
[WDM]: https://github.com/Maher4Ever/wdm

{% footnotes %}
<p id="footnote-1">
[1]: <a href="http://stackoverflow.com/a/6318188/1177636">在 Windows 7 上添加 Python Path</a> by melhosseiny.
{% reverse_footnote 1 %}
</p>
{% endfootnotes %}
