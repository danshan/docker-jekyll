FROM ruby:2.1
MAINTAINER i@shanhh.com

RUN apt-get update \
    && apt-get install -y \
        nodejs \
        python-pygments \
    && apt-get clean

RUN gem install \
    github-pages \
    jekyll \
    jekyll-redirect-from \
    kramdown \
    rdiscount \
    rouge

VOLUME /src
EXPOSE 4000

WORKDIR /src
ENTRYPOINT ["jekyll"]
