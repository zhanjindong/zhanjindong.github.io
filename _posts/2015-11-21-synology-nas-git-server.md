---
layout: post
title: "Synology DSM Git Server配置"
description: "Synology DSM Git Server配置"
categories: [NAS]
tags: [NAS]
alias: [/2015/11/21/]
utilities: fancybox,unveil,highlight
---

1、首先安装Git Server,进入“套件中心”找到点击安装即可。


2、然后打开 DSM 的SSH: 控制面板 → 终端机... → 启动SSH功能。

<a class="post-image" href="/assets/images/posts/nas-ssh.png">
<img itemprop="image" data-src="/assets/images/posts/nas-ssh.png" src="/assets/js/unveil/loader.gif" alt="nas-ssh.png" />
</a>

3、创建“共享文件夹” **repository** 作为我的Git仓库。

控制面板 → 共享文件夹：我就挂了一个盘，目录一般就是 **/volume1/repository**.

<a class="post-image" href="/assets/images/posts/nas-repository.png">
<img itemprop="image" data-src="/assets/images/posts/nas-repository.png" src="/assets/js/unveil/loader.gif" alt="nas-repository.png" />
</a>


4、创建和配置Git Server用户（根据需要，默认admin管理员当然可以）。

1）控制面板 → 用户账号：我这里创建了一个gituser用户，并设置了对repository目录的读写权限。

<a class="post-image" href="/assets/images/posts/nas-user.png">
<img itemprop="image" data-src="/assets/images/posts/nas-user.png" src="/assets/js/unveil/loader.gif" alt="nas-user.png" />
</a>

2）主菜单 → Git Server: 勾选用户。

<a class="post-image" href="/assets/images/posts/nas-git-user.png">
<img itemprop="image" data-src="/assets/images/posts/nas-git-user.png" src="/assets/js/unveil/loader.gif" alt="nas-git-user.png" />
</a>








