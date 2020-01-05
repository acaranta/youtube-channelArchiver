## Youtubedl Channel Archiver

## Requirements :
* a media directory where to save your videos, mounted on ```/ytdl/media```
* a config dir mounted on /ytdl/config, containing a file named ```channel_list.txt``` listing 1 playlist per line, the plaulists you want to dl
* (optional) A loop wait (in seconds, defaults to 7200) env var (named RUNEVERY) which the container will wait between two runs

## run :
```
docker run --ti -rm -e RUNEVERY=7200 -v <configdir>:/ytdl/config -v <mediadir>:/ytdl/media acaranta/youtube-channelarchiver
```
