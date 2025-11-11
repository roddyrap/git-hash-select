FROM ubuntu:latest

RUN apt update && apt install -y fzf git

RUN git config --global user.email "you@example.com"
RUN git config --global user.name " Your Name"

ADD ../git-hash-select_1.0.0-1_all.deb /app/

WORKDIR /app/

RUN dpkg -i git-hash-select*.deb
