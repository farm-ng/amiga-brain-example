#!/bin/bash

Help()
{
    echo "options:"
    echo "start    Start syncing to an Amiga"
    echo "stop     Stop syncing to an Amiga"
    echo "status   Display current sync sessions"
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

Help

state=""

while getopts s: flag
do
    case "${flag}" in
        s) state=${OPTARG};;
    esac
done

if [ ! -f /usr/local/bin/mutagen ]
then
    mkdir -p /tmp/mutagen
    cd /tmp/mutagen
    wget -c https://github.com/mutagen-io/mutagen/releases/download/v0.15.4/mutagen_linux_amd64_v0.15.4.tar.gz -O /tmp/mutagen/current.tar.gz
    tar xzf current.tar.gz
    sudo cp -f mutagen /usr/local/bin/
    sudo mkdir -p /usr/local/libexec
    sudo cp -f mutagen-agents.tar.gz /usr/local/libexec/
    rm -rf /tmp/mutagen
fi

if [[ $state == "start" ]]; then
    mutagen sync create --name=amiga \
        -i "**/build*" \
        -i "Dockerfile" \
        -i ".gitignore" \
        -i "sync.sh" \
        -i ".*" \
        -i "!.vscode" \
        -i "**/*venv*" \
        --sync-mode=one-way-safe \
        $DIR \
        amiga:/data/home/amiga/code/
elif [[ $state == "stop" ]]; then
    mutagen sync terminate amiga
elif [[ $state == "status" ]]; then
    mutagen sync list
else
    echo "state must be either 'start or stop"
fi
