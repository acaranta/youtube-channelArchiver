#!/bin/bash
CONFIGDIR="/ytdl/config"

COOKIES=""
if [ -f "$CONFIGDIR/cookies.txt" ]
then
	echo "Detected Cookies jar, using it"
	COOKIES="--cookies $CONFIGDIR/cookies.txt"
fi

youtube-dl --playlist-reverse --download-archive $CONFIGDIR/downloaded.txt -i -o "/ytdl/media/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(uploader)s - %(title)s [%(id)s].%(ext)s" -f bestvideo[ext=mp4]+bestaudio[ext=m4a] --merge-output-format mp4 --add-metadata --write-thumbnail --batch-file=$CONFIGDIR/channel_list.txt $COOKIES
#youtube-dl --playlist-reverse --download-archive $CONFIGDIR/downloaded.txt -i -o "/ytdl/media/%(uploader)s/%(playlist)s/%(playlist)s - S01E%(playlist_index)s - %(title)s [%(id)s].%(ext)s" -f bestvideo[ext=mp4]+bestaudio[ext=m4a] --merge-output-format mp4 --add-metadata --write-thumbnail --batch-file=$CONFIGDIR/channel_list.txt $COOKIES
