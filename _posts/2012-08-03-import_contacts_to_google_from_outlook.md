---
layout: post
title: outlook联系人批量导入google
date: 2012-08-03 17:15
description: "现在Android平台的手机非常流行, 很多人都选择了功过google帐号来同步和管理联系人.<br/>
手机上对联系人管理效率非常的低, 在web上管理速度又很慢.<br/>
我下面说说我自己的解决方案."
tags: [outlook, vba, goolge, gmail]
image:
  feature: abstract-7.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

现在Android平台的手机非常流行, 很多人都选择了功过google帐号来同步和管理联系人.
手机上对联系人管理效率非常的低, 在web上管理速度又很慢.
我下面说说我自己的解决方案.

从用智能手机开始, 我就习惯了用Outlook对我的联系人进行管理, 随着这几年换过很多操作系统的手机, 都是支持和Outlook直接进行同步的, 包括windows smartphone, windows pocket pc, blackberry, palm os, ios, symbian...唯独碰到android这朵奇葩, 默认只支持google帐号同步, 于是就牵扯到从outlook -&gt; google 和 google -&gt; outlook双向同步的问题.

虽然outlook支持contacts导出为csv而且google联系人也支持导入csv, 但是我非常不推荐这种格式, 她会把你联系人信息里的头像都丢失了, 这里推荐使用vCard名片格式导入.

那么接下来就是要解决outlook的联系人批量导出和google批量导入的问题了. 会涉及一点点编程的东西, 很简单, 一点一点说. 以outlook 2010为例. 其他版本的outlook类似.

## **准备工作** ##

启动outlook的开发工具.

outlook 2010默认是隐藏了这个功能的, 我们需要开启它.

outlook菜单栏 -&gt; 文件 -&gt; 选项, 打开**outlook选项**, 在**自定义功能区**的**主选项卡**中勾选**开发工具**.

[![outlook选项]({{ site.cdn }}/files/2012/08/outlook_1-300x239.jpg)]({{ site.cdn }}/files/2012/08/outlook_1.jpg)

这个时候在主选项卡中应该可以看到'开发工具'选项卡了.

[![outlook选项卡]({{ site.cdn }}/files/2012/08/outlook_2-300x117.jpg)]({{ site.cdn }}/files/2012/08/outlook_2.jpg)

## **outlook批量导出联系人** ##

1\. 先在c:根目录创建一个文件夹**contacts**, 用来保存导出的联系人文件.

2\. 在**开发工具** -> **宏** 中创建一个宏, `export`.

[![创建宏export]({{ site.cdn }}/files/2012/08/outlook_3-300x206.jpg)]({{ site.cdn }}/files/2012/08/outlook_3.jpg)

3\. 填入代码

{% highlight vbnet %}
Sub export()
Dim MyContacts As Outlook.MAPIFolder
Dim ContItem As Outlook.ContactItem
Dim SaveIndex As Integer

Set MyContacts = Application.GetNamespace("MAPI").GetDefaultFolder(olFolderContacts) 

SaveIndex = 0
For Each ContItem In MyContacts.Items
    FileName = "c:\contacts\" & SaveIndex & ".vcf"
    ContItem.SaveAs FileName, olVCard
    SaveIndex = SaveIndex + 1
    Next

End Sub
{% endhighlight %}

4\. 执行这段脚本.

[![执行vba脚本]({{ site.cdn }}/files/2012/08/outlook_4-300x141.jpg)]({{ site.cdn }}/files/2012/08/outlook_4.jpg)

网上也有一些教程提供了类似的代码, 无非都是用联系人名称作为导出到的vcf文件名, 我不推荐这样做, 因为谁也难保自己的联系人里会不会有重名的现象, 而且我们后期的目标是批量上传这批文件, 所以对这些文件的名称没有要求. 我直接用递增的数字作为文件名, 以保证每个联系人都能准确输出.

5\. 检查一下看看c:\contacts是不是已经保存了你所有的联系人, 如果保存成功, 第一步的导出工作已经成功.

## **google批量导入联系人** ##

这一步是为了将上一步导出的所有联系人导入到google.
我们观察一下google 联系人的导入功能就会发现, 它一次只能导入一个vcf文件, 下面我们就要解决将多个vcf文件合并的操作.
可以尝试用记事本打开一个vsf看看, 就会发现其实vcf就是一个文本文件, 以`BEGIN:VCARD`开始, 以`END:VCARD`结束, 这样就方便了, 我们可以尝试合并这些文本文件了.

* 开始菜单 -> 运行, 输入"cmd"打开命令行程序. 执行下面的操作:

{% highlight bash %}
    cd c:\contacts
    c:
    copy *.vcf all.vcf
{% endhighlight %}
这一步执行了将所有vcf文件合并到all.vcf的操作, 下面就可以一次性导入google联系人了.

[![google导入vcf联系人]({{ site.cdn }}/files/2012/08/outlook_6-249x300.jpg)]({{ site.cdn }}/files/2012/08/outlook_6.jpg)

## **关于google导出和outlook导入联系人** ##

这里又是一个很麻烦的东西, 我研究过google的导出的功能, 虽然支持csv和vcard(vcf)两种方式, 但是都会导致联系人头像等信息丢失的发生, 所以我依然不推荐使用google联系人来管理你的通讯录, 我更倾向于, 使用outlook来管理, 然后清空google的联系人以后, 重新导入到google.
