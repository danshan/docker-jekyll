---
layout: post
title: 解决Outlook批量导出联系人到Linux中Evolution中文乱码 
date: 2010-11-21 11:35
description: "有些喜欢使用linux的用户可能会选择evolution来收邮件, 但是从outlook导出到evolution的联系人, 所有的中文全部变成乱码, 主要是由于编码错误造成的, 下面来解决这个问题."
category: Tech
tags: [outlook, evolution, linux, encoding]
---

先参考[outlook联系人批量导入google](/blog/2012/08/03/import_contacts_to_google_from_outlook/), 将outlook联系人到windows下一个指定的文件夹中, **注意导出后先不要编辑这些文件**.

把整个文件夹复制到Linux中的一个文件夹, 并通过shell进入该文件夹. 执行:

{% highlight bash %}
$ cat *.vcf > all.vcf
$ gedit all.vcf
{% endhighlight %}

在gedit中对`all.vcf`文件**另存为**, 在另存为的时候, 选择编码方式为`utf-8`即可.

然后在Evolution中导入另存的文件, 我的通讯录好像没有什么信息丢失.
