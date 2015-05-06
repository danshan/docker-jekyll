---
layout: post
title: Sublime Text的Package Control插件配置proxy
date: 2012-11-13 11:35
description: "Sublime Text中的default的**package control**中对proxy似乎并没有生效, 始终无法浏览插件列表, 查了不少资料, 应该是对https的代理设置上有点问题. 下面说一下解决方案."
category: Tech
tags: [sublime text, proxy, package control]
---

Sublime Text中的default的**package control**中对proxy似乎并没有生效, 始终无法浏览插件列表, 查了不少资料, 应该是对https的代理设置上有点问题. 下面说一下解决方案.

尝试修改package control中的`repository`从**https**改为**http**:

From:
{% highlight python %}
"repository_channels": [
"https://sublime.wbond.net/repositories.json"
]
{% endhighlight %}

To:
{% highlight python %}
"repository_channels": [
"http://sublime.wbond.net/repositories.json"
]
{% endhighlight %}

File: Package Control.py

From:
{% highlight python %}
url = download['url']
{% endhighlight %}

To:
{% highlight python %}
url = download['url'].replace('https','http')
{% endhighlight %}

最后, 在配置package control的`http_proxy`应该就没有问题了
