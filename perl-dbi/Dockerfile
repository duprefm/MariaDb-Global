FROM perl

RUN cpanm DBI && mkdir -p /usr/src/app

WORKDIR /usr/src/app

ONBUILD COPY cpanfile* /usr/src/myapp

ONBUILD RUN DBI install

ONBUILD COPY . /usr/src/app

RUN cpanm DBD::mysql && mkdir -p /usr/src/app

WORKDIR /usr/src/app

ONBUILD COPY cpanfile* /usr/src/myapp

ONBUILD RUN DBD install --force

ONBUILD COPY . /usr/src/app

WORKDIR /usr/src/myapp
