FROM ubuntu:latest
MAINTAINER timmykmobile

RUN apt-get update

####################
# INSTALLATIONS
####################
RUN apt-get install -y unionfs-fuse && \
    apt-get install -y nano && \
    rm -rf /var/lib/apt/lists/*

ENV NUMBER_OF_DIRECTORIES=2 \
    SOURCE_SUBDIR_RW= \
    SOURCE_SUBDIR_RO1= \
    SOURCE_SUBDIR_RO2= \
    SOURCE_SUBDIR_RO3=

#RUN groupadd --gid 1000 abc \
#    && useradd --uid 1000 --gid abc --shell /bin/bash --create-home abc

#USER abc

COPY docker-entrypoint.sh /

RUN echo user_allow_other >> /etc/fuse.conf \
    && chmod +x /docker-entrypoint.sh

#ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["/docker-entrypoint.sh"]
