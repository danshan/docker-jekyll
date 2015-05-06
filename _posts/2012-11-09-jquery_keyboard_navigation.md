---
layout: post
title: jekyll实现页面键盘快捷键
date: 2012-11-09 10:35
description: "在jekyll生成的文章页面加上了键盘快捷键导航, `左方向键`或`H`导航到上一篇文章, `右方向键`或`L`导航到下一篇."
category: Tech
tags: [javascript, jekyll, jquery]
---

在jekyll生成的文章页面加上了键盘快捷键导航, 左方向键浏览上一篇文章, 右方向键导航到下一篇.

{% highlight javascript %}
$(function(){
  $(document).keydown(function(e) {
    var url = false;
    if (e.which == 37 || e.which == 72) {  // Left arrow and H
      {% if page.previous %}
        url = '{{page.previous.url}}';
      {% endif %}
    } else if (e.which == 39 || e.which == 76) {  // Right arrow and L
      {% if page.next %}
        url = '{{page.next.url}}';
      {% endif %}
    }
    if (url) {
      window.location = url;
    }
  });
})
{% endhighlight %}
