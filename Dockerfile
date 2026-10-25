# deno is the JS runtime yt-dlp uses to solve YouTube's signature challenges
FROM denoland/deno:bin-2.9.7 AS deno

FROM ubuntu:22.04
MAINTAINER Arthur Caranta <arthur@caranta.com>

RUN apt-get update && apt-get install -y ca-certificates ffmpeg openssl python3 aria2 curl
RUN ln -s /usr/bin/python3 /usr/local/bin/python
#RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl && chmod a+rx /usr/local/bin/youtube-dl
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/youtube-dl && chmod a+rx /usr/local/bin/youtube-dl

COPY --from=deno /deno /usr/local/bin/deno

# Try to run it so we know it works
RUN youtube-dl --version && deno --version

RUN mkdir -p /ytdl/config
RUN mkdir /ytdl/media
ADD ytdlrun.sh /ytdl
WORKDIR /ytdl
ENV RUNEVERY 7200

CMD /ytdl/ytdlrun.sh ; while true; echo "Waiting $RUNEVERY seconds before next run of youtube-dl"; sleep $RUNEVERY; do /ytdl/ytdlrun.sh; done      

