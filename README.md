# Simple Docker Container for Jekyll Work

Docker Hub: <https://registry.hub.docker.com/u/danshan/docker-jekyll/>

Use example:

```
docker run --rm -v "$PWD:/src" danshan/docker-jekyll build
```

or for repeated calls:

```
alias jekyll='sudo docker run --rm -v "$PWD:/src" -p 4000:4000 danshan/docker-jekyll'
jekyll build
jekyll serve -H 0.0.0.0
```

run as a background daemon:
```
docker run -d -v "$PWD:/src" -p 4000:4000 danshan/docker-jekyll serve -H 0.0.0.0
```

### Goodies
 - Supports pygments syntax highlighting
  - Supports Github Pages
   - Supports Jekyll Redirect From
    - Supports Kramdown
     - Supports RDiscount
      - Supports Rouge


## License: Public Domain

      Do what you want!

---

# HPSTR Jekyll Theme

They say three times the charm, so here is another free responsive Jekyll theme for you. I've learned a ton since open sourcing [my first two themes](https://mademistakes.com/work/jekyll-themes/), and wanted to try a few new things this time around. If you've used my previous themes most of this should be familiar territory.

## What HPSTR brings to the table:

* Modern and minimal design.
* Responsive templates for post, page, and post index `_layouts`. Looks great on mobile, tablet, and desktop devices.
* Gracefully degrades in older browsers. Compatible with Internet Explorer 8+ and all modern browsers.  
* Sweet animated menu with support for drop-downs.
* Optional [Disqus](http://disqus.com) comments and social sharing links.
* [Open Graph](https://developers.facebook.com/docs/opengraph/) and [Twitter Cards](https://dev.twitter.com/docs/cards) support for a better social sharing experience.
* Simple [custom 404 page](http://mmistakes.github.io/hpstr-jekyll-theme/404.html) to get you started.
* Stylesheets for Pygments and Coderay [syntax highlighting](http://mmistakes.github.io/hpstr-jekyll-theme/code-highlighting-post/) to make your code examples look snazzy
* [Available in Spanish](https://github.com/cruznick/hpstr-jekyll-theme/tree/es). Thanks [@cruznick](https://github.com/cruznick)!

![HPSTR Theme Preview screenshot](http://mmistakes.github.io/hpstr-jekyll-theme/images/hpstr-jekyll-theme-preview.jpg)

## Getting Started

HPSTR takes advantage of Sass and data files to make customizing easier. These features require Jekyll 2.x and will not work with older versions of Jekyll.

To learn how to install and use this theme check out the [Setup Guide](https://mmistakes.github.io/hpstr-jekyll-theme/theme-setup/) for more information.
