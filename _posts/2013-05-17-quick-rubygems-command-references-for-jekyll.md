---
layout: post
title: "Jekyll 使用过程中的一些常用的 RubyGems 命令"
description: "记录一些在维护及使用 Jekyll 时所经常用到的 RubyGems 命令。"
categories: [notes]
tags: [jekyll, ruby]
alias: [/2013/05/17/]
---
`gem --help` 显然会是很有用且值得一读的，可惜过长，故挑出以下一些命令作为常用参考。

## 安装/卸载 gem

	gem install jekyll
	gem uninstall jekyll

## 安装某特定版本的 gem

	gem install pygments.rb --version 0.4.2

## 卸载某特定版本的 gem

提示 'Select gem to uninstall' 并让用户选择

	gem uninstall jekyll

卸载指定版本

	gem uninstall jekyll --version 1.0.1
	gem uninstall jekyll --version '<1.0.1'

移除所有旧版本的 Jekyll

	gem cleanup jekyll

## 列出所有本地的 gem

	gem list --local

## 列出所有的 gem

	gem list --all

## 列出所有 Jekyll 的 gem

	gem list jekyll

## 更新已安装的 gem

	gem update

## 更新已安装的系统 gem

	gem update --system
