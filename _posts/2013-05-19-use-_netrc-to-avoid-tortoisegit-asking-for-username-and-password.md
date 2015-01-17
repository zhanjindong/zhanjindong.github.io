---
layout: post
title: "如何使用 _netrc 来避免 TortoiseGit 要求输入用户名和密码"
description: "如何使用 _netrc 来避免 TortoiseGit 要求输入用户名和密码。"
categories: [notes]
tags: [git, tortoisegit, windows]
alias: [/2013/05/19/]
---
1. 从文件管理器打开 `%USERPROFILE%`
2. 新建一个文件，名为 `_netrc`
3. 在文件中输入以下几行：

> machine github.com<br />
> login yizeng<br />
> password the_password<br />
