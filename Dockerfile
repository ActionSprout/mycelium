FROM neo4j:3.1.6

#################
## NEO4J PLUGINS

ENV APOC_JAR apoc-3.1.3.7-all.jar
ENV APOC_URI https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.1.3.7/apoc-3.1.3.7-all.jar

# https://neo4j.com/developer/kb/how-do-i-use-cypher-to-connect-to-a-rbms-using-jdbc/
ENV JDBC_PG_JAR postgresql-9.4.1209.jar
ENV JDBC_PG_URI https://jdbc.postgresql.org/download/postgresql-9.4.1209.jar
# ENV JDBC_PG_JAR postgresql-42.1.4.jar
# ENV JDBC_PG_URI https://jdbc.postgresql.org/download/postgresql-42.1.4.jar

RUN mkdir /plugins

RUN curl --fail --show-error --location --output /plugins/$APOC_JAR $APOC_URI
RUN curl --fail --show-error --location --output /plugins/$JDBC_PG_JAR $JDBC_PG_URI

#########
## JRUBY

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk update
RUN apk add jruby
RUN apk add jruby-irb jruby-rake
RUN jgem install bundler

ENV JRUBY_HOME=/usr/share/jruby
ENV PATH $JRUBY_HOME/bin:$PATH
ENV BUNDLE_SILENCE_ROOT_WARNING=1

RUN mkdir -p $JRUBY_HOME/etc && { echo 'install: --no-document'; echo 'update: --no-document'; } >> $JRUBY_HOME/etc/gemrc

###############
## Application

ENV INSTALL_PATH /app_root
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# Copy all our app's directories
COPY . .

RUN bundle install

