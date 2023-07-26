#!/bin/bash
sudo cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/ 
sudo systemctl enable tmp.mount
