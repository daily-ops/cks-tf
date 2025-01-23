ROUTE=`ip route | grep default | grep enp0s3 2>&1 > /dev/null`

if [ $? = 0 ]; then

    cat > /etc/systemd/system/disable-default-route.service <<-EOF
        [Unit]
        Description=Network Disable Default Route Configuration
        Documentation=man:systemd-networkd.service(8)
        After=systemd-networkd.service
        Wants=systemd-networkd.service

        [Service]
        ExecStart=ip route delete default dev enp0s3

        [Install]
        WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable disable-default-route
    systemctl start disable-default-route

    echo "* * * * * ip route delete default dev enp0s3" | sudo tee /etc/cron.d/delete_default_route

fi