---
layout: post
title: "Mac Today 自定义 widget"
date: 2015-07-14 17:48
description: "自定义一些比较简单的widget"
tags: [mac]
image:
  feature: abstract-6.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

自己是一个 [GTD](https://zh.wikipedia.org/wiki/GTD) 拥护者, 在常规使用电脑的时候, 也会做很多适合自己的配置.

这里主要提到的是对 Mac 系统的 Today Widget 做一点点配置, 让他更适合自己的使用.

先看看我自己的配置

<img src="{{ site.cdn }}/files/2015/07/widget-01.png{{ site.img }}">

这里用到了一个不错的 [Today-Scripts](https://github.com/SamRothCA/Today-Scripts) 开源软件. 安装以后, 可以在 Today 中增加多个 script, 用于执行系统命令.

我这里用的就是 

{% highlight sh %}
cal | grep --before-context 6 --after-context 6 --color -e "$(date +%e)" -e "^$(date +%e)"

/usr/local/bin/icalBuddy -f -sd eventsToday+3
{% endhighlight %}

<img src="{{ site.cdn }}/files/2015/07/widget-02.png{{ site.img }}">

第一个命令不用说了, 用于显示日历. 第二个命令用到了另一个工具 [icalBuddy](http://hasseg.org/icalBuddy/), 用于显示近几日的日程.

用同样的方式, 我又增加了一个脚本, 只是做一个很简单的 cat 操作, 用于做一个简单的便签操作.

<img src="{{ site.cdn }}/files/2015/07/widget-03.png{{ site.img }}">

另外在写了一个 alfred 的 workflow 用于写入这个文件. 只贴了关键代码, 实现起来很简单.

* Script Filter

{% highlight sh %}
note='{query}'

echo '<?xml version="1.0"?>'
echo '<items>'
echo '<item uid="'$time'" arg="'$note'">'
    echo '<title>Add note "'$note'"</title>'
    echo '<subtitle></subtitle>'
    echo '<icon>icon.png</icon>'
echo '</item>'
echo '</items>'
{% endhighlight %}

* Run Script

{% highlight sh %}
note='{query}'
time=`date "+%Y-%m-%d %H:%M:%S"`
file="/Users/Dan/cloud/nutstore/notes"

echo "$time" >> "$file"
echo "$note" >> "$file"
echo "-------------------"  >> "$file"
echo >> "$file"
{% endhighlight %}


