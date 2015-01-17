---
layout: post
title: "在运行时更新 App.config 里的 AppSettings 属性及自定义配置节"
description: "如何在运行时更新（添加，修改或删除）App.config 里的 AppSettings 属性及自定义配置节"
categories: [articles, popular]
tags: [c#, .net]
alias: [/2013/08/31/]
utilities: highlight
---
本文展示了如何在运行时更新（添加，修改或删除）`App.config` 里的 `AppSettings`
属性及自定义配置节。

* Kramdown table of contents
{:toc .toc}

## App.config 文件
{: #app-config}

{% highlight xml %}
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <configSections>
        <sectionGroup name="geoSettings">
            <section name="summary" type="System.Configuration.NameValueSectionHandler" />
        </sectionGroup>
    </configSections>

    <appSettings>
        <add key="Language" value="Ruby" />
        <add key="Version" value="1.9.3" />
    </appSettings>

    <geoSettings>
        <summary>
            <add key="Country" value="New Zealand" />
            <add key="City" value="Christchurch" />
        </summary>
    </geoSettings>
</configuration>
{% endhighlight %}

## 更新 AppSettings
{: #update-appsettings}

### 添加一个元素
{: #add-in-appsettings}

{% prettify c# %}
var config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
config.AppSettings.Settings.Add("OS", "Linux");
config.Save(ConfigurationSaveMode.Modified);

ConfigurationManager.RefreshSection("appSettings");
{% endprettify %}

### 修改已有元素的键值
{: #edit-in-appsettings}

{% prettify c# %}
var config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
config.AppSettings.Settings["Version"].Value = "2.0.0";
config.Save(ConfigurationSaveMode.Modified);

ConfigurationManager.RefreshSection("appSettings");
{% endprettify %}

### 删除已有的元素
{: #remove-in-appsettings}

{% prettify c# %}
var config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
config.AppSettings.Settings.Remove("Version");
config.Save(ConfigurationSaveMode.Modified);

ConfigurationManager.RefreshSection("appSettings");
{% endprettify %}

## 更新自定义配置节
{: #update-custom-section}

### 添加一个元素
{: #add-in-custom-section}

{% prettify c# %}
var xmlDoc = new XmlDocument();
xmlDoc.Load(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);

// create new node <add key="Region" value="Canterbury" />
var nodeRegion = xmlDoc.CreateElement("add");
nodeRegion.SetAttribute("key", "Region");
nodeRegion.SetAttribute("value", "Canterbury");

xmlDoc.SelectSingleNode("//geoSettings/summary").AppendChild(nodeRegion);
xmlDoc.Save(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);

ConfigurationManager.RefreshSection("geoSettings/summary");
{% endprettify %}

### 修改已有元素的键值
{: #edit-in-custom-section}

{% prettify c# %}
var xmlDoc = new XmlDocument();
xmlDoc.Load(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);

xmlDoc.SelectSingleNode("//geoSettings/summary/add[@key='Country']").Attributes["value"].Value = "Old Zeeland";
xmlDoc.Save(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);

ConfigurationManager.RefreshSection("geoSettings/summary");
{% endprettify %}

### 删除已有的元素
{: #remove-in-custom-section}

{% prettify c# %}
var xmlDoc = new XmlDocument();
xmlDoc.Load(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);

XmlNode nodeCity = xmlDoc.SelectSingleNode("//geoSettings/summary/add[@key='City']");
nodeCity.ParentNode.RemoveChild(nodeCity);

xmlDoc.Save(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile);
ConfigurationManager.RefreshSection("geoSettings/summary");
{% endprettify %}

## 输出全部元素
{: #print-out-keys}

{% prettify c# %}
NameValueCollection appSettings = ConfigurationManager.AppSettings;
// var customSettings = ConfigurationManager.GetSection("geoSettings/summary") as NameValueCollection;

foreach (string key in appSettings.AllKeys) {
    Console.WriteLine("{0}: {1}", key, section[key]);
}
{% endprettify %}

## 参考文献
{: #references}

1. [Modifying app.config at runtime throws exception](http://stackoverflow.com/q/8807218/1177636)
2. [update app.config file programatically with ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);](http://stackoverflow.com/q/8522912/1177636)
3. [Opening the machine/base Web.Config (64bit) through code](http://stackoverflow.com/q/8130085/1177636)
