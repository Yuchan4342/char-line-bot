FROM ruby:2.6.6
ENV LANG C.UTF-8
# update node version
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get install -y nodejs
RUN apt-get update -qq && apt-get install -y \
        build-essential postgresql-client \
        && rm -rf /var/lib/apt/lists/*
RUN mkdir /workdir
WORKDIR /workdir
ADD Gemfile /workdir/Gemfile
ADD Gemfile.lock /workdir/Gemfile.lock
RUN gem install bundler
RUN bundle install
RUN apt update
ADD . /workdir
