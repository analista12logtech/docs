#!/bin/bash
# Update the system
#sudo apt-get update
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
sleep 10
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
sleep 2
sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
sleep 2
sudo chown prometheus:prometheus /usr/local/bin/node_exporter
sleep 5
rm -rf node_exporter-1.8.2.linux-amd64.tar.gz node_exporter-1.8.2.linux-amd64
sleep 2 
sudo touch /etc/systemd/system/node_exporter.service
echo "[Unit]
Description=node_exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/node_exporter.service
sleep 2
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
exit
echo "node_exporter installation Completed!!! "
