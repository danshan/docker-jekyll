---
layout: post
title: BlackBerry中设置EditFiled的边框
date: 2012-11-08 14:35
description: "BlackBerry中为`EditField`设置边框"
tags: [blackberry, ui, border]
image:
  feature: abstract-2.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

对于Rom版本在4.6及以上时, 使用下面的方法, 参考[Blackberry JDE API](http://www.blackberry.com/developers/docs/4.6.0api/index.html):

{% highlight java %}
BasicEditField roundedBorderEdit = new BasicEditField();
XYEdges padding = new XYEdges(15, 15, 15, 15);
int color = Color.CRIMSON;
int lineStyle = Border.STYLE_DOTTED;
Border roundedBorder = BorderFactory.createRoundedBorder(padding, color, lineStyle);
roundedBorderEdit.setBorder(roundedBorder);

BasicEditField bevelBorderEdit = new BasicEditField();
XYEdges edges = new XYEdges(10, 10, 10, 10);
XYEdges outerColors = new XYEdges(Color.BLACK, Color.WHITE, Color.BLACK, Color.WHITE);
XYEdges innerColors = new XYEdges(Color.WHITE, Color.BLACK, Color.WHITE, Color.BLACK);
Border bevelBorder = BorderFactory.createBevelBorder(edges, outerColors, innerColors);
bevelBorderEdit.setBorder(bevelBorder);
{% endhighlight%}

对于Rom版本在4.5及以下时, 就只能通过`draw bitmap`的方法去实现了:

{% highlight java %}
class BorderedEdit extends BasicEditField {
    Bitmap mBorder = null;

    public BorderedEdit(Bitmap borderBitmap) {
        mBorder = borderBitmap;
    }

    protected void paint(Graphics graphics) {
        graphics.drawBitmap(0, 0, mBorder.getWidth(), mBorder.getHeight(), mBorder, 0, 0);
        super.paint(graphics);
    }
}
{% endhighlight %}