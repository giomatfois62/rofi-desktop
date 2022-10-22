#!/bin/bash
# dmenu_ffmpeg
# Copyright (c) 2021 M. Nabil Adani <nblid48[at]gmail[dot]com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# required
# - ffmpeg
# - rofi
# - libpulse
# - xorg-xdpyinfo
# - jq
# - pulseaudo/pipewire-pulse

DMENU="rofi -dmenu -i"
VIDEO="$HOME/Videos/record"
AUDIO="$HOME/Music/record"
recordid="/tmp/recordid"

function getInputAudio() {
    pactl list | grep "Name" | grep "alsa" | awk '{print $2}' | $DMENU -p "Input Audio " -theme-str 'window {width: 30%;} listview {lines: 5;}'
}

function audioVideo() {
    filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
    dimensions=$(xdpyinfo | grep dimensions | awk '{print $2;}')
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Recording" "With:\nVideo On\nAudio On"
        ffmpeg -y -f x11grab -framerate 30 -s $dimensions \
            -i :0.0 -f pulse -i $audio -ac 1 \
            -c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 \
            -c:a aac $filename &

        echo $! >$recordid
    fi
}

function video() {
    filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
    dimensions=$(xdpyinfo | grep dimensions | awk '{print $2;}')

    notify-send "Start Recording" "With:\nVideo On\nAudio Off"
    ffmpeg -y -f x11grab -framerate 30 -s $dimensions \
        -i :0.0 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
        -c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 $filename &

    echo $! >$recordid
}

function audio() {
    filename="$AUDIO/audio-$(date '+%y%m%d-%H%M-%S').mp3"
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Recording" "With:\nVideo Off\nAudio On"
        ffmpeg -f pulse -i $audio -ac 1 -acodec libmp3lame -ab 128k $filename &

        echo $! >$recordid
    fi
}

function stream() {
    output=$2
    platform=$1
    dimensions=$(xdpyinfo | grep dimensions | awk '{print $2;}')
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Streaming On $platform" "With:\nVideo On\nAudio On"
        ffmpeg -y -f x11grab -framerate 23 -s $dimensions \
            -i :0.0 -f pulse -i $audio -ac 1 \
            -c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 \
            -b:v 500k -b:a 128k \
            -vf scale=854x480 \
            -f flv $output &

        echo $1 >$recordid
    fi
}

function getStreamToken() {
    $DMENU -p "Stream" -mesg "Insert $1 Token" -lines 0
}

function startStreaming() {
    platform="$1"
    streamurl="$2"
    token=$(getStreamToken "$platform")

    if [ -z "$token" ]; then
        exit
    else
        stream "$platform" "$streamurl$token"
    fi
}

function streamOnFacebook() {
    startStreaming "Facebook" "rtmps://live-api-s.facebook.com:443/rtmp/"
}

function streamOnNimoTv() {
    startStreaming "Nimo TV" "rtmp://txpush.rtmp.nimo.tv/live/"
}

function streamOnTwitch() {
    startStreaming "Twitch" "rtmp://sin.contribute.live-video.net/app/"
}

function streamOnYoutube() {
    startStreaming "Youtube" "rtmp://a.rtmp.youtube.com/live2/"
}

function streamOnVimeo() {
    startStreaming "Vimeo" "rtmps://rtmp-global.cloud.vimeo.com:443/live/"
}

function stoprecord() {
    if [ -f $recordid ]; then
        kill -15 $(cat $recordid)
        rm $recordid
    fi

    sleep 5
    if [ "$(pidof ffmpeg)" != "" ]; then
        pkill ffmpeg
    fi
}

function endrecord() {
    OPTIONS='["Yes", "No"]'
    select=$(echo $OPTIONS | jq -r ".[]" | $DMENU -p "Record" -mesg "Stop Recording" -theme-str 'window {width: 30%;} listview {lines: 2;}')
    [ "$select" == "Yes" ] && stoprecord
}

function startrecord() {
    OPTIONS='''
    [
        ["Audio & Video",        "audioVideo"],
        ["Video Only",         "video"],
        ["Audio Only",         "audio"],
        ["Stream On Facebook", "streamOnFacebook"],
        ["Stream On Nimo TV",  "streamOnNimoTv"],
        ["Stream On Twitch",   "streamOnTwitch"],
        ["Stream On Youtube",  "streamOnYoutube"],
        ["Stream On Vimeo",    "streamOnVimeo"]
    ]
    '''
    select=$(echo $OPTIONS | jq -r ".[][0]" | $DMENU -p "Record" -theme-str 'window {width: 30%;} listview {lines: 8;}')

    if [ ${#select} -gt 0 ]; then
        eval $(echo $OPTIONS | jq -r ".[] | select(.[0] == \"$select\") | .[1]")
    else
        exit 1
    fi
}

function createSaveFolder() {
    if [ ! -d $VIDEO ]; then
        mkdir -p $VIDEO
    fi
    if [ ! -d $AUDIO ]; then
        mkdir -p $AUDIO
    fi
}

createSaveFolder

if [ -f $recordid ]; then
    endrecord
else
    startrecord
fi
