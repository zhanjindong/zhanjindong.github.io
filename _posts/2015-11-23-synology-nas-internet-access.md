---
layout: post
title: "Synology NAS 外部访问"
description: "Synology NAS 外部访问"
categories: [articles]
tags: [NAS]
alias: [/2015/11/23/]
utilities: fancybox,unveil,highlight
---

Synology NAS 能够随时随地的外部访问使其可以称之为“私有云”了，虽然NAS的概念早在云之前。其实Synology NAS都有一个外部IP，通过Synology的**QuickConnect** ID就可以
在外面访问，但是如果已经有一个自己的域名了，能够通过个性化的域名访问最好不过了。

1、DDNS

首先你需要设置你的域名进行动态解析。之前我的域名在dnspod.cn，发现Synology不支持，最后我转到了花生壳上面，70一年也还好。但花生壳不支持对根域名进行CNAME，我之前是将
jindong.io映射到GitHub上的，没办法只能改成www了。然后将jindong.io DDNS到了NAS上。设置很简单：控制面板 → 外部访问 → DDNS，按照要求设置就可以了。


2、路由器端口转发

设置也很简单：控制面板 → 外部访问 → 路由器配置，NAS内部应用很多应用端口已经固定了，比如WEB是80，SSH是22等等，一一绑定到路由器对应的端口就可以了。
但像80和22这些知名端口我发现一个问题，直接映射好像有问题。可以先到路由器将80或22映射成其他的比如9999和2222，然后再在DSM里设置，最后再到路由里改回去就可以了。



3、HTTPS

通过上面的设置后你会发现在外网还是无法访问80端口，这是因为被可恶运营商给禁掉了，网站得备案才能解禁。不过Synology可以设置HTTPS，控制面板 → WEB服务 → 启动WEB服务的HTTPS连接。
但是Synology使用的是自签的证书，安全性很差，一般浏览器都会警告的。









