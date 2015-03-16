FROM debian:wheezy
MAINTAINER Dan Shan "i@shanhh.com"

ENV DEBIAN_FRONTEND noninteractive

ADD install.sh install.sh
RUN chmod +x install.sh && ./install.sh && rm install.sh

EXPOSE 4000
VOLUME ["/src"]
WORKDIR /src
CMD ["jekyll", "serve", "--host=0.0.0.0", "--watch"]
