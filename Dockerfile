# Run to build docker image mainnet:
#   docker build --build-arg VERSION=v0.18.0 -t bethington/bitcoind:v0.18.0 .
# Run to build docker image testnet:
#   docker build --build-arg VERSION=v0.18.0 --build-arg PARAMS=-testnet -t bethington/bitcoind:v0.18.0-testnet .
# Must use bitcoin as the container name like so:
#   docker run --name bitcoin -p 9332:9332 -p 9333:9333 -e USER=MyUser -e PASS=MyPass -v ./data:/data bethington/bitcoind
FROM ubuntu:18.04
MAINTAINER Ben Ethington <benaminde@gmail.com>

# Install necessary tools and libraries
RUN apt-get update
RUN apt-get -y install git nano curl wget net-tools
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

ARG VERSION
ENV VERSION ${VERSION}

# Compile download and bitcoind
RUN cd ~ \
 && git clone https://github.com/bitcoin/bitcoin.git --branch ${VERSION} --single-branch \
 && cd bitcoin \
 && ./autogen.sh \
 && ./configure CPPFLAGS="-I/root/build/include/ -O2" LDFLAGS="-L/root/build/lib/" --with-gui=no \
 && make \
 && make install \
 && cd ~ \
 && rm -R build \
 && rm -R bitcoin

VOLUME /root/.bitcoin

EXPOSE 8332 8333

WORKDIR /root/.bitcoin

# Must use rpcbind and rpcallowip to access RPC and REST externally
CMD bitcoind -datadir=/root/.bitcoin/data
