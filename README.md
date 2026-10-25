# YouTube Channel Archiver

A Docker image that keeps a local archive of YouTube channels and playlists up to date. It runs [yt-dlp](https://github.com/yt-dlp/yt-dlp) over a list of URLs on a fixed interval, downloads only what it has not fetched before, and names files by season and episode so a media server (Plex, Jellyfin, Kodi…) can index each playlist as a show.

## How it works

On start, then every `RUNEVERY` seconds, the container runs [`ytdlrun.sh`](ytdlrun.sh), which:

1. Updates yt-dlp to the latest release (`youtube-dl -U`). If the update fails, the run carries on with the installed version.
2. Downloads every playlist listed in `/ytdl/config/channel_list.txt`, oldest video first (`--playlist-reverse`), so episode numbers stay stable as new videos appear.
3. Records each downloaded video ID in `/ytdl/config/downloaded.txt` and skips those IDs on later runs.
4. Fetches the best MP4 video plus the best M4A audio, merges them into one `.mp4`, embeds the metadata and saves the thumbnail.

A video that fails is skipped (`-i`) and retried on the next run.

The image ships yt-dlp (installed as `/usr/local/bin/youtube-dl`), ffmpeg for merging, and [deno](https://deno.com/). yt-dlp needs deno as its JavaScript runtime to solve YouTube's signature challenges; without it most downloads fail with `HTTP Error 403: Forbidden`.

## Quick start

Create a config directory with the list of URLs to archive:

```bash
mkdir -p ytdl/config ytdl/media
echo "https://www.youtube.com/@SomeChannel/videos" > ytdl/config/channel_list.txt
```

Run the container:

```bash
docker run -d --name youtube-archiver --restart unless-stopped \
  -e YTOPTIONS="-4" \
  -v "$PWD/ytdl/config:/ytdl/config" \
  -v "$PWD/ytdl/media:/ytdl/media" \
  acaranta/youtube-channelarchiver:latest
```

Follow the progress with `docker logs -f youtube-archiver`. Between runs the container logs `Waiting 7200 seconds before next run of youtube-dl`.

## Configuration

### Volumes

| Path in container | Required | Content |
|---|---|---|
| `/ytdl/config` | yes | `channel_list.txt` (you write it), `downloaded.txt` (written by the container), optional `cookies.txt` |
| `/ytdl/media` | yes | The downloaded videos |

### Files in `/ytdl/config`

| File | Description |
|---|---|
| `channel_list.txt` | One channel, playlist or video URL per line. Lines starting with `#`, `;` or `]` are comments. |
| `downloaded.txt` | yt-dlp's download archive: one `youtube <id>` line per video already fetched. Delete a line to download that video again. |
| `cookies.txt` | Optional. Netscape-format cookie jar, passed to yt-dlp with `--cookies` when present. Needed for age-restricted videos. |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `RUNEVERY` | `7200` | Seconds to wait between two runs. |
| `YTOPTIONS` | *(empty)* | Extra yt-dlp options added in front of the built-in ones, e.g. `-4 --retries 5 --limit-rate 2M`. The value is split on spaces, so an option value cannot itself contain a space. |

### Output layout

Files are written as:

```
/ytdl/media/<playlist>/<playlist> - S01E<index> - <uploader> - <title> [<video id>].mp4
```

plus the thumbnail next to each video. `<index>` is the video's position in the playlist counted from the oldest.

The container runs as root, so the files it writes are owned by root on the host.

## Docker Compose

```yaml
services:
  youtubearchiver:
    image: acaranta/youtube-channelarchiver:latest
    environment:
      - RUNEVERY=7200
      - YTOPTIONS=-4 --retries 5 --yes-playlist
    volumes:
      - ./ytdl/config:/ytdl/config
      - ./ytdl/media:/ytdl/media
    restart: always
```

## Troubleshooting

| Log message | Cause and fix |
|---|---|
| `ERROR: unable to download video data: HTTP Error 403: Forbidden` | yt-dlp is out of date or cannot run deno. Check the start of the run for `No supported JavaScript runtime could be found`; if it appears, the image is older than the deno change: pull the current one. |
| `Sign in to confirm your age` | The video is age-restricted. Add a `cookies.txt` exported from a logged-in YouTube session (see the [yt-dlp guide on exporting YouTube cookies](https://github.com/yt-dlp/yt-dlp/wiki/Extractors#exporting-youtube-cookies); use a private window so YouTube does not rotate the cookies). |
| `Sign in to confirm you're not a bot` | YouTube is blocking the source IP. This is common over IPv6 tunnels and datacenter ranges. Force IPv4 with `YTOPTIONS=-4`, or route through another address with `--proxy`. |
| `Requested format is not available` | The video has no MP4 video stream or no M4A audio stream. The format selection in `ytdlrun.sh` has no fallback, so such videos are skipped. |
| `Your yt-dlp version … is older than 90 days!` | The self-update at the start of each run failed (no network, GitHub unreachable). It is retried on the next run. |

## Building

```bash
docker build -t acaranta/youtube-channelarchiver:latest .
```

The build checks that both yt-dlp and deno run. deno comes from the pinned `denoland/deno:bin-<version>` stage at the top of the [`Dockerfile`](Dockerfile).

### CI

[`.drone.yml`](.drone.yml) uses the shared `docker-build-multiarch.yaml` Drone template. Every push to `master` builds a `linux/amd64` image and pushes it to Docker Hub as `acaranta/youtube-channelarchiver:latest`.

## Project layout

| File | Role |
|---|---|
| [`Dockerfile`](Dockerfile) | Ubuntu 22.04 image with ffmpeg, yt-dlp and deno; loops `ytdlrun.sh` every `RUNEVERY` seconds. |
| [`ytdlrun.sh`](ytdlrun.sh) | One archive pass: self-update, then yt-dlp over `channel_list.txt`. |
| [`.drone.yml`](.drone.yml) | Drone CI stub that builds and pushes the image. |
