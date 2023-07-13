#!/bin/sh

function testPort(){
  command nc -z -w1 $1 $2 &>/dev/null
}

function killProcess() {
 ps -ef | grep $1 | grep -v grep  | awk '{print $2}'  | sort -r | xargs -I {} kill -9 "{}"
}

if [ -z "$SSH_CONNECTION" ]; then 
  if ! testPort 192.168.43.1 8022; then
    echo "start sshd"
    sshd
  fi

  if ! testPort 192.168.43.1 8080; then
    echo "start rclone serve"
    nohup rclone serve webdav $HOME/storage/downloads --addr 192.168.43.1:8080 &>/dev/null &
  fi

  trap "killProcess sshd; killProcess rclone" EXIT
fi

if testPort 192.168.43.168 7890; then
  echo "set proxy 192.168.43.168:7890"
  export https_proxy=http://192.168.43.168:7890 
  export http_proxy=http://192.168.43.168:7890
  export all_proxy=socks5://192.168.43.168:7890
fi
