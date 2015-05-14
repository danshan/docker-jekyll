---
layout: post
title: Java 计算两个时间点的间隔时间
date: 2015-05-08 15:20
description: "需求只有一句话: 显示宝宝出生到现在, xx年xx个月xx天."
tags: [java]
image:
  feature: abstract-12.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

在做一个需求的时候, 碰到一个非常难办的需求:

用户在设置了宝宝出生日期的时候, 在页面上显示宝宝的年龄. 显示的格式为 "xx年xx个月xx天".

乍一看很简单, 直接用 getTime() 减出毫秒数, 然后去模除就行了. 但是这个算法存在非常多的问题:

1. 每个月的天数不一致.
2. 如果时间跨度中有个闰年, 就非常恶心了.

当然, 大部分情况下有个几天的差距是看不出来的, 但是如果碰到一些比较极端的情况, 比如生日是 2011-01-01 到 2015-01-01 去查看的时候, 由于中间隔了一个2012的闰年, 这个问题就复杂了, 而且由于刚好是同一天, 所以哪怕有一点点差别都能发现是bug.

既然要做成通用的房费类, 那么干脆就做一个精准点的算法: "xx年xx月xx日xx小时xx分钟xx秒".

基本设想如下, 类似于整数的减法, 只是每一位的进制不同.

比如月份的进制为12, 日的进制和当前所在的月有关, 小时的进制是24, 分钟进制是60.

很明显, 这里最复杂的就是月了. 当月份需要借位的时候, 需要计算 endDate 的上一个月的总天数.

基本思想说完了, 上代码

{% highlight java %}
private static class DateInterval {
    private int year;
    private int month;
    private int day;
    private int hour;
    private int minute;
    private int second;

    private Date start;
    private Date end;
    private Calendar sCal = Calendar.getInstance();
    private Calendar eCal = Calendar.getInstance();

    public DateInterval(Date start, Date end) {
        Assert.isTrue(end.after(start));

        this.start = start;
        this.end = end;

        sCal.setTime(start);
        eCal.setTime(end);

        year = eCal.get(Calendar.YEAR) - sCal.get(Calendar.YEAR);
        month = eCal.get(Calendar.MONTH) - sCal.get(Calendar.MONTH);
        day = eCal.get(Calendar.DAY_OF_MONTH) - sCal.get(Calendar.DAY_OF_MONTH);
        hour = eCal.get(Calendar.HOUR_OF_DAY) - sCal.get(Calendar.HOUR_OF_DAY);
        minute = eCal.get(Calendar.MINUTE) - sCal.get(Calendar.MINUTE);
        second = eCal.get(Calendar.SECOND) - sCal.get(Calendar.SECOND);
    }

    @Override
    public String toString() {
        return MessageFormatter.arrayFormat("{}年{}月{}日{}小时{}分钟{}秒", new Object[] {
                year, month, day, hour, minute, second
        });
    }

    public DateInterval calcInterval() {

        if (month < 0) {
            descYear();
        }
        if (day < 0) {
            descMonth();
        }
        if (hour < 0) {
            descDay();
        }
        if (minute < 0) {
            descHour();
        }
        if (second < 0) {
            descMintue();
        }

        return this;
    }

    private void descYear() {
        year--;
        month += 12;
    }

    private void descMonth() {
        if (--month < 0) {
            descYear();
        }
        // 当天天数要加上结束月的上个月的总天数
        day += calDaysOfLastMonth();
    }

    private void descDay() {
        if (--day < 0) {
            descMonth();
        }
        hour += 24;
    }

    private void descHour() {
        if (--hour < 0) {
            descDay();
        }
        minute += 60;
    }

    private void descMintue() {
        if (--minute < 0) {
            descHour();
        }
        second += 60;
    }

    private int calDaysOfLastMonth() {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, eCal.get(Calendar.YEAR));
        calendar.set(Calendar.MONTH, eCal.get(Calendar.MONTH));
        calendar.add(Calendar.MONTH, -1);
        return calendar.getActualMaximum(Calendar.DATE);
    }
}
{% endhighlight %}

这里最复杂的一段就是在借位减法上, 如果借位导致了前一位的值为负值, 那么要再向前借位.

测试代码

{% highlight java %}
public static void main(String[] args) throws ParseException {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    System.out.println(calcDateInterval(sdf.parse("2010-01-01 19:00:01"), sdf.parse("2015-01-01 19:00:00")));
}
{% endhighlight %}

返回如下:

```
4年11月30日23小时59分钟59秒
```