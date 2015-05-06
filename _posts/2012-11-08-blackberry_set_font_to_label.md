---
layout: post
title: BlackBerry中设置LabelFiled字体
date: 2012-11-08 12:35
description: "BlackBerry中为`LabelField`设置字体"
category: BlackBerry
tags: [blackberry, ui, font]
---

可以直接使用`LabelField.setFont`, 下面提供两种例子去设置font.

第一种是使用已有的字体:

{% highlight java %}
LabelField labelField = new LabelField("Hello World");
Font myFont = Font.getDefault().derive(Font.BOLD, 9, Ui.UNITS_pt);
labelField.setFont(myFont);
{% endhighlight%}

另一种是通过FontFamily获取font:

{% highlight java %}
LabelField labelField = new LabelField("Hello World");
FontFamily fontFamily = FontFamily.forName("BBCasual");
Font myFont = fontFamily.derive(Font.ITALIC, 12, Ui.UNITS_pt);
labelField.setFont(myFont);
{% endhighlight %}

两个例子中有个地方注意一下: 我使用了`UNITS_pt(points)`而不是`UNITS_px(pixels)`. 确实应该这么用, 因为黑莓通常屏幕尺寸和分辨率(DPI)都很小, 使用`UNITS_pt`可以带来更一致性的体验.

在第二个例子中, `forName`可能抛出**ClassCastException**, 你需要catch一下, 这个在文档中虽然没写, 但如果你使用了一个未知的name, 就可能出错.

官方还提供了一个例子:

{% highlight java %}
LabelField displayLabel = new LabelField("Test", LabelField.FOCUSABLE) {
    protected void paintBackground(net.rim.device.api.ui.Graphics g) {
        g.clear();
        g.getColor();
        g.setColor(Color.CYAN);
        g.fillRect(0, 0, Display.getWidth(), Display.getHeight());
        g.setColor(Color.BLUE);               
    }
};  

FontFamily fontFamily[] = FontFamily.getFontFamilies();
Font font = fontFamily[1].getFont(FontFamily.CBTF_FONT, 8);
displayLabel.setFont(font);
{% endhighlight %}

参考: [Dynamic LabelField Change Font](http://supportforums.blackberry.com/rim/board/message?board.id=java_dev&thread.id=37988)
