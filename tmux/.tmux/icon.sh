#!/usr/bin/env bash
case "$1" in
  nvim|vim)     echo " $1" ;;
  node)         echo " $1" ;;
  python|python3) echo " $1" ;;
  git)          echo " $1" ;;
  docker)       echo " $1" ;;
  ssh)          echo " $1" ;;
  htop|btop)    echo " $1" ;;
  lazygit)      echo " $1" ;;
  ruby|irb)     echo " $1" ;;
  cargo|rustc)  echo " $1" ;;
  go)           echo " $1" ;;
  claude)       echo "󰮯 $1" ;;
  *)            echo " $1" ;;
esac
