#!/bin/bash

NODEIP=$(curl -s4 icanhazip.com)

# Create systemd Service File
cd /etc/systemd/system
echo "Starting Bitindi service..."
echo "
        [Unit]
        Description=Bitindi Node Service
        [Service]
        Type=simple
        Restart=always
        RestartSec=1
        User=$USER
        Group=$USER
        LimitNOFILE=4096
        WorkingDirectory=/$USER/validator/bitindichain
        ExecStart=/$USER/validator/bitindichain/bitindi server --data-dir /$USER/validator/bitindichain/data-dir  --chain /$USER/validator/genesis.json --grpc 0.0.0.0:10000 --libp2p 0.0.0.0:10001 --jsonrpc 0.0.0.0:10002 --nat $NODEIP --seal
        [Install]
        WantedBy=multi-user.target
" | sudo tee bitindi.service

if grep -q ForwardToSyslog=yes "/etc/systemd/journald.conf"; then
  sudo sed -i '/#ForwardToSyslog=yes/c\ForwardToSyslog=no' /etc/systemd/journald.conf
  sudo sed -i '/ForwardToSyslog=yes/c\ForwardToSyslog=no' /etc/systemd/journald.conf
elif ! grep -q ForwardToSyslog=no "/etc/systemd/journald.conf"; then
  echo "ForwardToSyslog=no" | sudo tee -a /etc/systemd/journald.conf
fi
cd -
echo

# Start systemd Service
sudo systemctl force-reload systemd-journald
sudo systemctl daemon-reload
sudo systemctl start bitindi.service

read -n 1 -s -r -p "Service successfully started! Press any key to continue..."
