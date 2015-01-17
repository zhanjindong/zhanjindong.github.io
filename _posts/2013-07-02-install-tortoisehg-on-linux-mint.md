---
layout: post
title: "在 Linux Mint 上安装 TortoiseHg"
description: "如何通过官方 PPA 在 Linux Mint 15 上安装 TortoiseHg。"
categories: [notes]
tags: [linux mint, tortoisehg]
alias: [/2013/07/02/]
---
本文记录了如何通过官方 [TortoiseHg Release PPA][TortoiseHg Release PPA] 在 Linux Mint 15 上安装 [TortoiseHg][TortoiseHg]。

**注意**：

- 不推荐同时也向系统添加 [Mercurial PPA][Mercurial PPA]， 因为 TortoiseHg 对于同何版本的 Mercurial 共同工作有着严格的要求。
- [TortoiseHg PPA Stable Snapshots][TortoiseHg PPA Stable Snapshots] 提供了最新稳定版本的安装包。

**步骤**：

1. 向系统添加 [TortoiseHg Release PPA][TortoiseHg Release PPA]

	> sudo add-apt-repository ppa:tortoisehg-ppa/releases

2. 更新软件包及依赖关系

	> sudo apt-get update

3. 安装 `tortoisehg` 软件包

	> sudo apt-get install tortoisehg

4. 测试安装是否成功

	> hg \--version

	终端输出示例：

	   Mercurial Distributed SCM (version 2.8.2)
	   (see http://mercurial.selenic.com for more information)

	   Copyright (C) 2005-2013 Matt Mackall and others
	   This is free software; see the source for copying conditions. There is NO
	   warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

[TortoiseHg]: http://tortoisehg.bitbucket.org/
[TortoiseHg Release PPA]: https://launchpad.net/~tortoisehg-ppa/+archive/releases
[Mercurial PPA]: https://launchpad.net/~mercurial-ppa/+archive/releases
[TortoiseHg PPA Stable Snapshots]: https://launchpad.net/~tortoisehg-ppa/+archive/stable-snapshots
[TortoiseHg Release PPA]: https://launchpad.net/~tortoisehg-ppa/+archive/releases

