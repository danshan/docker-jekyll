---
layout: post
title: Java循环遍历不定长数组链表
date: 2012-08-21 14:45
description: "功能描述一个链表中保存多个不同长度的数组, 根据一个索引值, 能取到对应的元素所在的数组下标"
tag: [java]
image:
  feature: abstract-9.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---
功能描述
一个链表中保存多个不同长度的数组, 根据一个索引值, 能取到对应的元素所在的数组下标

{% highlight java %}
public static int[] calcIndexArr(final List<String[]> list, int index) {
    int listSize;
    if (list == null || (listSize = list.size()) == 0) {
        return new int[0];
    }

    int max = 1;
    for (int i = 0; i < list.size(); i++) {
        max *= list.get(i).length;
    }
    while (index >= max) {
        index -= max;
    }

    int[] indexArr = new int[list.size()];

    for (int i = 0; i < listSize; i++) {
        int b = 1;
        for (int j = i + 1; j < listSize; j++) {
            b *= list.get(j).length;
        }
        int a = index / b;
        indexArr[i] = a;
        index = index - a * b;
    }
    return indexArr;
}
{% endhighlight %}

测试方法:
{% highlight java %}
public void testCalcIndexArr() {
    List<String[]> list = new ArrayList<String[]>();
    list.add(new String[2]);
    list.add(new String[4]);
    list.add(new String[1]);
    for (int i = 0; i < 30; i++) {
        int arr[] = RandName.calcIndexArr(list, i);
        assertEquals(3, arr.length);
        System.out.println(arr[0] + "," + arr[1] + "," + arr[2]);
    }
}
{% endhighlight %}

测试结果:

    0,0,0
    0,1,0
    0,2,0
    0,3,0
    1,0,0
    1,1,0
    1,2,0
    1,3,0
    0,0,0
    0,1,0
    0,2,0
    0,3,0
    1,0,0
    1,1,0
    1,2,0
    1,3,0
    0,0,0
    0,1,0
    0,2,0
    0,3,0
    1,0,0
    1,1,0
    1,2,0
    1,3,0
    0,0,0
    0,1,0
    0,2,0
    0,3,0
    1,0,0
    1,1,0

