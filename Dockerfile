FROM ruby:2.6
# update node version
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get install -y nodejs
RUN apt-get update -qq && apt-get install -y \
        build-essential \
        && rm -rf /var/lib/apt/lists/*
RUN mkdir /workdir
WORKDIR /workdir
ADD Gemfile /workdir/Gemfile
ADD Gemfile.lock /workdir/Gemfile.lock
RUN gem install bundler
RUN bundle install
RUN apt update
# for rails erd
# RUN apt install -y graphviz
ADD . /workdir
