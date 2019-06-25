# Run to build docker image: docker build --build-arg VERSION=v0.18.0 --build-arg PARAMS=-testnet -t bethington/bitcoind:v0.18.0 .
FROM ubuntu:18.04
MAINTAINER Ben Ethington <benaminde@gmail.com>

ARG VERSION
ARG PARAMS
ENV VERSION ${VERSION}
ENV PARAMS ${PARAMS}

# Install necessary tools and libraries
RUN apt-get update
RUN apt-get -y install git nano curl wget
RUN apt-get -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
 && apt-get clean
RUN apt-get -y install libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev \
                       libboost-chrono-dev libboost-test-dev libboost-thread-dev \
 && apt-get clean

# Install BerkeleyDB 4.8 to maintain binary wallet compatibility
RUN cd ~ \
 && wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
 && tar -xvf db-4.8.30.NC.tar.gz \
 && cd db-4.8.30.NC/build_unix \
 && mkdir -p build \
 && ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=/root/build \
 && make install \
 && cd ~ \
 && rm -R db-4.8.30.NC \
 && rm db-4.8.30.NC.tar.gz
 
# Block and Transaction Broadcasting with ZeroMQ
RUN apt-get -y install libzmq3-dev \
 && apt-get clean
 
# Compile download and bitcoind
RUN cd ~ \
 && git clone https://github.com/bitcoin/bitcoin.git --branch ${VERSION} --single-branch \
 && cd bitcoin \
 && ./autogen.sh \
 && ./configure CPPFLAGS="-I/root/build/include/ -O2" LDFLAGS="-L/root/build/lib/" --with-gui=no \
 && make \
 && make install \
 && rm -R build \
 && rm -R bitcoin

VOLUME /bitcoin

EXPOSE 8332 8333

WORKDIR /bitcoin

CMD bitcoind -datadir=/bitcoin -server -rest ${PARAMS}
