# syslog-ng
A container for running syslog-ng. This simply installs syslog-ng and lets you
configure it to run either on Docker or Kubernetes.

## Running on Docker

This volume expects to listen on two ports and have two mounted volumes. It
needs to listen on port 514 TCP and 514 UDP. It needs to have `/logs` mounted
and `/etc/syslog-ng` mounted.

    docker run --rm -it -p 514:514/tcp -p 514:514/udp -v $PWD/logs:/logs -v $PWD/example:/etc/syslog-ng ghcr.io/paullockaby/syslog-ng:latest

