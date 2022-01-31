#!/bin/bash
DATE=$(date)
/usr/bin/curl -s --head  --request GET https://www.displayr.com | if ! grep "HTTP/2 200"; then
sudo service httpd restart
echo "$DATE - NOT OKAY, apache restarted" >> /var/log/httpd/custom-restarts.log
else
echo "$DATE - Apache running fine"
fi
