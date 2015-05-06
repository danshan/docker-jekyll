---
layout: post
title: "vim解决/bin/bash^M: bad interpreter错误"
date: 2012-08-21 14:50
description: "可以有很多种办法看这个文件是DOS格式的还是UNIX格式的, 还是MAC格式的. 比如:<br/>
`vim filename`<br/>
然后用命令`:set ff?`可以看到dos或unix的字样."
tags: [vim, sed, linux]
image:
  feature: abstract-11.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

可能是你的脚本文件是DOS格式的, 即每一行的行尾以**\r\n**来标识, 其ASCII码分别是_0x0D_, _0x0A_. 而Unix只有**\n**.
可以有很多种办法看这个文件是DOS格式的还是UNIX格式的, 还是MAC格式的. 比如

{% highlight bash %}
vim filename
{% endhighlight %}

然后用命令`:set ff?`可以看到dos或unix的字样.

如果确实是dos的换行方式, 出现这个问题的原因, 通常是该文本文件由windows通过ftp上传, 或者直接从windows下copy的一段代码, 导致了换行方式不同. 只要把文件中的**\r**换行符删除就好了.

可以在上传的时候选择ascii text模式

或者手动转换

方法1:
{% highlight bash %}
sed -i "s/\r//" <filename>
{% endhighlight %}

方法2:

Vim中执行`:%s/^M//g`

**^M中的^不是Shift+6, 而是先按Ctr-V 再按 Ctrl-M**
