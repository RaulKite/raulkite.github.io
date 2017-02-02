FROM ruby:2.2

MAINTAINER Raul Sanchez "raul@um.es"

RUN mkdir /blog 

WORKDIR /blog

ADD Gemfile /blog/Gemfile
ADD Gemfile.lock /blog/Gemfile.lock

RUN gem install json -v '1.8.3' && bundle install

ADD ./ /blog

ENTRYPOINT ["jekyll", "serve", "-H", "0.0.0.0"]

