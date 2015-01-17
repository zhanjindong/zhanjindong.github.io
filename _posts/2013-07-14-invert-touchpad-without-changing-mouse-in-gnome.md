---
layout: post
title: "在 GNOME 中反转触摸板而不改变鼠标键位"
description: "如何在 Linux Mint 15 Cinnamon 中反转触摸板至左撇子键位，而同时保持正常鼠标键位。此文理论上也应对所有使用 GNOME 的 Ubuntu 系统有效。"
categories: [articles, popular]
tags: [linux mint]
alias: [/2013/07/14/]
utilities: fancybox, unveil
---
作为一个使用反转了左右键位的触摸板，却使用正常键位鼠标的左撇子用户，在安装了 Linux Mint 15 Cinnamon 桌面之后，不能从 "System Settings -> Mouse and Touchpad" 分别设置触摸板和鼠标的左右键位是一件很恼人的事情。

不过在经过了短暂的研究后，受此 [AskUbuntu 问答][AskUbuntu question]的启发，找到了一个简单的通过 [GSettings][GSettings] 来设置的解决方法。

* Kramdown table of contents
{:toc .toc}

## 反转触摸板
{: #invert-touchpad}

### 通过命令行
{: #using-cli}

在 Gsettings 里, `touchpad` 下面有一个子键叫做 `left-handed`，是用来控制触摸板的左右键位属性的，该子键是一个 string 类型，默认键值为 "mouse"，但可以设置成 "left" 或 "right"。

通过终端，输入以下命令来将其设成左利手键位：

	gsettings set org.gnome.settings-daemon.peripherals.touchpad left-handed left

### 通过图形化界面 "dconf-editor"
{: #using-gui}

Gsettings 有一个图形化工具叫做 "dconf-editor"， 它使用二进制大对象数据库来保存全部设置和键值。(两者之间的关系和 “Windows Regitry” 与 “regedit” 类似。)

1. 首先安装 `dconf-editor`, 在终端中输入：

	   sudo apt-get install dconf-tools

2. 然后通过 `Alt` + `F2`， 输入 `dconf-editor` 并键入 `Enter` 来打开它。

3. 在打开的 “dconf-editor” 窗口中输入 `Ctrl` + `F` 来搜索 `touchpad` 字段。

4. 在 `touchpad` 下点选子键 `left-handed` 并将其键值设置为 `left`。

<a class="post-image" href="/assets/images/posts/2013-07-14-dconf-editor-periperals-touchpad.png">
<img itemprop="image" data-src="/assets/images/posts/2013-07-14-dconf-editor-periperals-touchpad.png" src="/assets/js/unveil/loader.gif" alt="Invert touchpad from dconf-editor" />
</a>

## 反转鼠标
{: #invert-mouse}

如果也想将鼠标的左右键位反转，可以通过命令行、“系统设置”或是 "dconf-editor" 来进行。不过请注意 `peripherals.mouse` 下的子键 `left-handed` 所保存的键值是布尔类型，即只应被设置为 "true" 或 "false"。

	gsettings set org.gnome.settings-daemon.peripherals.mouse left-handed true

[GSettings]: https://developer.gnome.org/gio/2.34/GSettings.html
[AskUbuntu question]: http://askubuntu.com/q/83590/171955
