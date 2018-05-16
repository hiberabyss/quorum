FROM hbliu/quorum:latest

RUN apt-get update
RUN apt-get install -y python
RUN apt-get install -y curl
RUN apt-get install -y vim

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
