#!/bin/bash
while true ; do
  for entr in auto.sh ; do
    entry="${entr/.sh/}"
    tmux kill-session -t $entry
      rm -rf ~/.telegram-cli/data/sticker/*
      rm -rf ~/.telegram-cli/data/photo/*
      rm -rf ~/.telegram-cli/data/animation/*
      rm -rf ~/.telegram-cli/data/video/*
      rm -rf ~/.telegram-cli/data/audio/*
      rm -rf ~/.telegram-cli/data/voice/*
      rm -rf ~/.telegram-cli/data/temp/*
      rm -rf ~/.telegram-cli/data/thumb/*
      rm -rf ~/.telegram-cli/data/document/*
      rm -rf ~/.telegram-cli/data/profile_photo/*
      rm -rf ~/.telegram-cli/data/encrypted/*
      rm -rf ./data/photos/*
    tmux new-session -d -s $entry "./$entr"
    tmux detach -s $entry
  done
  echo Bots Running!
  sleep 1800
done
