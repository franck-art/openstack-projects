#!/bin/bash

# Install apache2

sudo apt update 

sudo apt install apache2 -y

sudo systemctl status apache2
