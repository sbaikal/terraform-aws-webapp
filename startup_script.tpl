#! /bin/bash
sudo amazon-linux-extras install -y nginx1
sudo service nginx start
sudo rm /usr/share/nginx/html/index.html
echo '<html><head><title>Home Assignment </title></head><body>Demo from Baikal!</body></html>' | sudo tee /usr/share/nginx/html/index.html