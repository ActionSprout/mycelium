# Start with our base Ruby (slim) image
FROM ruby:2.3.3-slim

LABEL authors="Kyle Rader <kyle@actionsprout.com>, Amiel Martin <amiel@actionsprout.com>"

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -qq -y --no-install-recommends \
      build-essential git

RUN apt-get install -qq -y --no-install-recommends \
      curl libpq-dev

ENV INSTALL_PATH /app_root
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# Copy all our app's directories
COPY . .

RUN gem update bundler
RUN bundle install

EXPOSE 80
