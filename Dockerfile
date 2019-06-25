# Run to build docker image: docker build -t bethington/bitcoind .
FROM ubuntu:xenial
MAINTAINER Ben Ethington <benaminde@gmail.com>

RUN apt-get update && apt-get upgrade \
              && apt-get install git nano curl cmake build-essential \
	      && libtool autotools-dev g++-multilib libtool \
	      && binutils-gold bsdmainutils pkg-config \
              && automake pkg-config bsdmainutils python3 \
	      && libssl-dev libevent-dev libboost-system-dev \
	      && libboost-filesystem-dev libboost-chrono-dev \
	      && libboost-test-dev libboost-thread-dev

#ENV HOME /bitcoin

# add user with specified (or default) user/group ids
#ENV PUID ${PUID:-1000}
#ENV PGID ${PGID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
#RUN groupadd -g ${PGID} bitcoin \
#	&& useradd -u ${PUID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

VOLUME bitcoin:/bitcoin

EXPOSE 8332 8333 18332 18333

WORKDIR /bitcoin

CMD /bin/bash
