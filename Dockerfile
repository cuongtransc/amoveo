# Author: Cuong Tran
#
# Build: docker build -t cuongtransc/app:0.1 .
# Run: docker run -d -p 8080:8080 --name app-run cuongtransc/app:0.1
#

FROM ubuntu:16.04
LABEL maintainer="cuongtransc@gmail.com"

ENV REFRESHED_AT 2018-05-14

RUN apt-get update -qq

# using apt-cacher-ng proxy for caching deb package
#RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142/";' > /etc/apt/apt.conf.d/01proxy

RUN apt-get install -yqq erlang libncurses5-dev libssl-dev unixodbc-dev g++ erlang-base-hipe git make curl

WORKDIR /app

COPY apps apps
COPY config config
COPY scripts scripts
COPY tests tests
COPY rebar.config rebar3 requirements.txt ./

# Build for development
RUN sed -i '$apubkey(1) -> testnet_sign:new_key().' apps/amoveo_http/src/api.erl

COPY Makefile.dev /app/Makefile

RUN make multi-build

VOLUME ["/app"]

# EXPOSE 8080 8443

COPY trap-sleep-infinity.sh /usr/local/bin/trap-sleep-infinity.sh
ENTRYPOINT ["trap-sleep-infinity.sh"]

CMD ["start"]
