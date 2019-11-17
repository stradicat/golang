#!/bin/bash

# Parameters:
# -b go_binary.tar.gz

function err() { 1>&2 echo "$0: error $@"; return 1; }

function downloadLatestGo () {
  GOURLREGEX='https://dl.google.com/go/go[0-9\.]+\.linux-amd64.tar.gz'
  echo "Finding latest version of Go for AMD64..."
  url="$(wget -qO- https://golang.org/dl/ | grep -oP 'https:\/\/dl\.google\.com\/go\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )"
  latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"
  echo "Downloading latest Go for AMD64: ${latest}"
  wget --quiet --continue --show-progress "${url}" -P $HOME/go/dl
  unset url
  unset GOURLREGEX
}

function removeGoTools () {
  rm -rf $HOME/go/tools/go
}

function removeDownload () {
  find $HOME/go/dl -name "go*" -type f -delete
}

function env () {
  if [[ -z "$GOROOT" ]] || [[ -z "$GOPATH" ]]; then
  
      # tools
      export GOROOT=$HOME/go/tools
      export PATH=$PATH:$GOROOT/bin

      # libraries 
      export GOPATH=$HOME/go/libraries
      export PATH=$PATH:$GOPATH/bin

      # workspace
      export GOPATH=$GOPATH:$HOME/go/workspace

      echo '
      
      #[Golang].................................
      
      # tools
      export GOROOT=$HOME/go/tools/go
      export PATH=$PATH:$GOROOT/bin

      # libraries
      export GOPATH=$HOME/go/libraries
      export PATH=$PATH:$GOPATH/bin

      # workspace
      export GOPATH=$GOPATH:$HOME/go/workspace

      #.................................[/Golang]
            
      ' >> ~/.profile && source ~/.profile

  fi
}


while getopts "b:" opt;
do
  case $opt in
    b) BINARY="$OPTARG" ;;
    :) err "Option -$OPTARG requires an argument.";;
    \?) err "Invalid option: -$OPTARG";;
  esac
done

if [ -z "$BINARY" ]; then

  echo "
   NOTE: The optional option: -b go_binary.tar.gz is missing.

   Trying to download the latest Go binary.
  "

  downloadLatestGo

  LATEST="$(find $HOME/go/dl -name "go*" -type f | head -n 1)"

  removeGoTools

  tar -C $HOME/go/tools -xzvf $LATEST

  env

  removeDownload

  go version

else

  echo $BINARY

  removeGoTools

  tar -C $HOME/go/tools -xzvf $BINARY

  env
  
  go version

fi
