#! /bin/bash

#export SOUNDBOARD_DIR=`dirname "$0"`
export SOUNDBOARD_DIR='/Users/michalwrobel/workspace/soundboard'
export SOUNDBOARD_MUSIC_DIR="$SOUNDBOARD_DIR/files"

SHELL_NAME=$(basename $SHELL)

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

autocompletion()
{
  if [[ $SHELL_NAME == 'bash']]; then
    cat <<EOS
    _soundboard_autocompl() {
      local cur=\${COMP_WORDS[COMP_CWORD]}

      if [[ "\$COMP_CWORD" == 1 ]]; then
        local names="play ls stop help"
        COMPREPLY=( \$(compgen -W "\$names" -- \$cur) )
      elif [[ "\$COMP_CWORD" == 2 && "\${COMP_WORDS[1]}" == "play" ]]; then
        local names=\$(ls $SOUNDBOARD_MUSIC_DIR)
        COMPREPLY=( \$(compgen -W "\$names" -- \$cur) )
      fi
    }
    complete -F _soundboard_autocompl $(basename $0)
EOS

  elif [[ $SHELL_NAME == "zsh" ]]; then
    cat <<EOS
    _soundbard_autocompl() {
      local word words
      read -cA words
      word="\${words[2]}"

      if [ "\${#words}" -eq 2 ]; then
        reply=(ls play stop help)
      elif [ "\${#words}" -eq 3 ] && [ "\$word" = "play" ]; then
        reply=(\`ls $SOUNDBOARD_MUSIC_DIR\`)
      fi
    }
    compctl -K _soundbard_autocompl $(basename $0)
EOS
  fi
}

case $action in
  "ls")
    list
    ;;
  "play")
    file=$2
    play "$file"
    ;;
  "autocompletion")
    autocompletion
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
