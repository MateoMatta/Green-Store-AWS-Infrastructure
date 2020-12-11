#!/bin/bash
sudo yum update -y
sudo yum install -y git 

#Clone salt repo
mkdir -p /srv/app
sudo chmod 777 /srv/app
git clone https://github.com/MateoMatta/Green-Store-AWS-Infrastructure /srv/app

#Instalar ansible
sudo amazon-linux-extras install ansible2

#Correr ansible
cd /srv/app/Infra/conf_ansible
sudo ansible-playbook playbook.yml

#Correr server back
cd /srv/app/aik-back
sudo node server.js

#Correr server front
cd /srv/app/aik-front
sudo node server.js
