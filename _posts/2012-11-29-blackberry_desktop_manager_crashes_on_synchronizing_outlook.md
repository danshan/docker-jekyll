---
layout: post
title: 解决使用BlackberryDesktopManager同步Outlook时崩溃问题
date: 2012-11-29 13:35
description: "通过**Blackberry Desktop Manager**将blackberry和**Outlook**同步的时候, 100%会在同步时直接崩溃. 经过反复测试和网上资料的搜集, fix了这个问题."
category: BlackBerry
tags: [desktop, blackberry, outlook, synchronization]
---

通过**Blackberry Desktop Manager**将blackberry和**Outlook**同步的时候, 100%会在同步时直接崩溃. 经过反复测试和网上资料的搜集, fix了这个问题.

下面有几种解决方案, 如果一个不管用, 请分别尝试.

1\. 扫描Outlook的PST文件尝试解决问题: 关闭Outlook后运行outlook的pst扫描程序**C:\Program Files\Microsoft Office\Office12\SCANPST.exe**, 它将尝试去修复一些由于pst文件异常造成的错误. 一些情况下可以解决你的Blackberry Desktop Manager崩溃问题.

2\. 卸载Blackberry Desktop Manager, 并以管理员方式安装: 先完全卸载Blackberry Desktop Manager, 然后对安装文件鼠标右击选"Run as administrator". 重新安装以后, 问题解决.

3\. 如果以上两种解决方案都失效的情况下, 可以尝试使用这种方案, 删除以前所有的同步信息, 以全新的方式重新同步: 关闭Blackberry Desktop Manager删除这个文件夹**C:\Documents and Settings\user_name\Application Data\Research In Motion\BlackBerry**, 然后打开Blackberry Desktop Manager并重新配置同步方案, 尝试同步. 我几次出现问题都是通过这种方案得到解决的.
