# Run to build docker image: docker build -t bethington/bitcoind .
FROM ubuntu:18.04
MAINTAINER Ben Ethington <benaminde@gmail.com>

RUN apt-get update
RUN apt-get -y install git nano curl wget
RUN apt-get -y install build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 \
 && apt-get clean
RUN apt-get -y install libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev \
                    && libboost-chrono-dev libboost-test-dev libboost-thread-dev \
 && apt-get clean

RUN cd ~ \
 && wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
 && tar -xvf db-4.8.30.NC.tar.gz \
 && cd db-4.8.30.NC/build_unix \
 && mkdir -p build \
 && export BDB_PREFIX="/root/build" \
 && ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX \
 && make install \
 && export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.4.8/include" \
 && export BDB_LIB_PATH="/usr/local/BerkeleyDB.4.8/lib" \
 && ln -s /usr/local/BerkeleyDB.4.8/lib/libdb-4.8.so /usr/lib/libdb-4.8.so
 
RUN cd / \
 && git clone https://github.com/bitcoin/bitcoin.git --branch v0.18.0 --single-branch
 && ./autogen.sh \
 && ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/" --with-gui=no --disable-wallet

#ENV HOME /bitcoin

# add user with specified (or default) user/group ids
#ENV PUID ${PUID:-1000}
#ENV PGID ${PGID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
#RUN groupadd -g ${PGID} bitcoin \
#	&& useradd -u ${PUID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

VOLUME /bitcoin

EXPOSE 8332 8333 18332 18333

WORKDIR /bitcoin

CMD /bin/bash
