FROM ubuntu:18.10
MAINTAINER Arthur Caranta <arthur@caranta.com>

RUN apt-get update && apt-get install -y ca-certificates ffmpeg openssl python3 aria2 
RUN apt-get install -y python3-pip git curl
RUN python3 -m pip install --upgrade pip
RUN pip3 install youtube-dl


# Try to run it so we know it works
RUN youtube-dl --version

RUN mkdir -p /ytdl/config
RUN mkdir /ytdl/media
ADD ytdlrun.sh /ytdl
WORKDIR /ytdl
ENV RUNEVERY 7200

CMD /ytdl/ytdlrun.sh ; while true; echo "Waiting $RUNEVERY seconds before next run of youtube-dl"; sleep $RUNEVERY; do /ytdl/ytdlrun.sh; done      

