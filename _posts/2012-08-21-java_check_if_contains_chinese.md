---
layout: post
title: Java判断字符串是否含有中文字符
date: 2012-08-21 15:15
description: "有时候需要验证一个字符串中是否含有中文这样的特殊的需求, 一般会采用两种方案, 一种就是最常见的正则表达式, 另一种效率较高, 但是不够严谨, 适用于不是非常精确的场合."
tags: [java, encoding]
image:
  feature: abstract-8.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

有时候需要验证一个字符串中是否含有中文这样的特殊的需求, 一般会采用两种方案, 一种就是最常见的正则表达式, 另一种效率较高, 但是不够严谨, 适用于不是非常精确的场合.

{% highlight java %}
String str = "测试中文";
System.out.println(str.getBytes().length == str.length); // 为false是则包含中文
{% endhighlight %}

### getBytes

{% highlight java %}
public byte[] **getBytes**(Charset charset)
{% endhighlight %}

使用给定的charset将此String编码到byte序列, 并将结果存储到新的byte数组.

此方法总是使用此字符集的默认代替byte数组替代错误输入和不可映射字符序列. 如果需要对编码过程进行更多控制, 则应该使用`CharsetEncoder`类.

**参数:**

:  _charset_ – 用于编码String的Charset

**返回:**

:  所得byte数组

**从以下版本开始:**

:  1.6

