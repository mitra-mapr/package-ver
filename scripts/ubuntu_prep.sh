#!/bin/bash

nohup /usr/sbin/sshd -D &

while true
do
sleep 60
done

