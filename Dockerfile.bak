FROM debian:wheezy
#FROM ruby:2.1
MAINTAINER Dan Shan "i@shanhh.com"

ENV DEBIAN_FRONTEND noninteractive

# ADD install.sh install.sh
# RUN sh ./install.sh && rm install.sh

RUN apt-get update 
RUN apt-get install -y ruby ruby-dev build-essential zlib1g-dev
RUN apt-get install -y node
#RUN apt-get install -y node python-pygments
RUN apt-get autoclean apt-get install clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install jekyll & bundler (therubyracer needed for coffeescript support, rouge for highlightning)
RUN gem sources --remove https://rubygems.org/
RUN gem sources --remove http://rubygems.org/
RUN gem sources -a https://ruby.taobao.org/
RUN gem sources -l
RUN gem install -V jekyll bundler rdiscount kramdown #--no-ri --no-doc
#RUN gem install -V jekyll bundler therubyracer rouge github-pages jekyll-redirect-from rdiscount kramdown --no-doc
#RUN gem install -V coffee-script-source -v 1.9.1
#RUN gem install -V coffee-script -v 2.3.0
#RUN gem install -V execjs -v 2.3.0

# prepare dir
RUN mkdir /src

EXPOSE 4000
VOLUME ["/src"]
WORKDIR /src
CMD ["bundle", "install"]
CMD ["jekyll", "serve", "--host=0.0.0.0", "--watch"]
