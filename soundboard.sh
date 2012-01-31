#! /bin/bash

export SOUNDBOARD_DIR=`dirname "$0"`
export SOUNDBOARD_MUSIC_DIR="$SOUNDBOARD_DIR/files"

usage() {
  echo "soundboard.sh"
  echo "Usage: "
  echo "   soundboard.sh - lists audio clips "
  echo "   soundboard.sh #1 - plays clip with number 1"
  echo "   soundboard.sh clip.mp3 - plays clip with name clip.mp3"
  echo "   soundboard.sh stop - stop playing"

  die
}

list()
{
  ls -rt $SOUNDBOARD_MUSIC_DIR | awk '{print NR,$0}'
}

stopPlay()
{
  killall afplay
}

play()
{
  local clip="$1"

  if [[ "$clip" =~ ^[0-9]+$ ]] ; then
    file=$(list | awk "NR==$clip {print;exit}" | sed "s/$clip //g")
  fi

  src="$SOUNDBOARD_MUSIC_DIR/$file"
  if [ -e "$src" ]
  then
    echo "Playing: $file"
    afplay "$src" &
  else
    echo "No such file: $src"
    die
  fi
}

die(){
  exit 1
}

if [ -z $1 ]
then
  list
  die
elif [ -n $1 ]
then
  action=$1
fi

case $action in
  "ls")
    list
    ;;
  "play")
    file=$2
    play "$file"
    ;;
  "stop")
    stopPlay
    ;;
  "--help" | "-h")
    usage
    ;;
  *)
    file=$1
    play "$file"
    ;;
esac
