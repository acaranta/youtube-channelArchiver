FROM ubuntu:18.10
MAINTAINER Arthur Caranta <arthur@caranta.com>

RUN apt-get update && apt-get install -y ca-certificates ffmpeg openssl python3 aria2 
RUN apt-get install -y python3-pip git curl
RUN python3 -m pip install --upgrade pip
RUN pip3 install youtube-dl


# Try to run it so we know it works
RUN youtube-dl --version

RUN mkdir -p /ytdl/{config,media}
WORKDIR /ytdl
ENV RUNEVERY 7200

CMD youtube-dl --playlist-reverse --download-archive /ytdl/config/downloaded.txt -i -o "/ytdl/media/%(uploader)s/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(title)s [%(id)s].%(ext)s" -f bestvideo[ext=mp4]+bestaudio[ext=m4a] --merge-output-format mp4 --add-metadata --write-thumbnail --batch-file=/ytdl/config/channel_list.txt ; while true; echo "Waiting $RUNEVERY seconds before next run of youtube-dl"; sleep $RUNEVERY; do youtube-dl --playlist-reverse --download-archive /ytdl/config/downloaded.txt -i -o "/ytdl/media/%(uploader)s/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(title)s [%(id)s].%(ext)s" -f bestvideo[ext=mp4]+bestaudio[ext=m4a] --merge-output-format mp4 --add-metadata --write-thumbnail --batch-file=/ytdl/config/channel_list.txt; done      

