#!/bin/bash

temp_dockercompose="$( mktemp -d )"
cd ${temp_dockercompose}

function _quit() {
  docker-compose stop
  cd ~/
  rm -rf ${temp_dockercompose}
}

cat > docker-compose.yml << EOF
version: '2'
service:
  dockerui:
    image: abh1nav/dockerui:latest
    name_container: dockerui 
    expose:
      - "9000"
    volumes:
      - /var/run/docker.sock:/docker.sock
    command: -e="/docker.sock"
    networks:
      device:
        bridge-dockerui
  browser-dockerui:
    image: jess/firefox
    name_container: broswer-dockerui
    link:
      - dockerui:dockerui
    environment:
      - DIPLAY
    volumes:
      - "$HOME/.Xauthority:/root/.Xauthority:rw"
    command: -no-remote http://dockerui:9000/
EOF

docker-compose up
