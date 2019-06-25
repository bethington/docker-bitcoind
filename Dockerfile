FROM ubuntu:xenial
MAINTAINER Ben Ethington <benaminde@gmail.com>

ENV HOME /bitcoin

# add user with specified (or default) user/group ids
ENV USER_ID ${PUID:-1000}
ENV GROUP_ID ${PGID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${PGID} bitcoin \
	&& useradd -u ${PUID} -g bitcoin -s /bin/bash -m -d /bitcoin bitcoin

VOLUME bitcoin:/bitcoin

EXPOSE 8332 8333 18332 18333

WORKDIR /bitcoin

CMD /bin/bash
