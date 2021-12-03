#!/usr/bin/bash

# Task 1: Create a project jumphost instance
# You will use this instance to perform maintenance for the project.
# Requirements:
# * Name the instance Instance name .
# * Use an f1-micro machine type.
# * Use the default image type (Debian Linux).
#======================rules======================
# 1) Create all resources in the default region or zone, unless otherwise directed.
# 2) Naming normally uses the format team-resource; for example, an instance could be named nucleus-webserver1.
# 3) Allocate cost-effective resource sizes. Projects are monitored, and excessive resource use will result in the containing project's termination (and possibly yours), so plan carefully. This is the guidance the monitoring team is willing to share: unless directed, use f1-micro for small Linux VMs, and use n1-standard-1 for Windows or other applications, such as Kubernetes nodes.
#=================================================
#check for the default region/zone configration and find the default settings
gcloud config get-value compute/zone
# if it didn't set yet. list all configurations to make sure
gcloud config list --all | grep "zone"
#find the project id and copy it
gcloud config list projects
#check the current project default settings for zone and region
# it will show the default zone and region settings. Note them somewhere.
# e.g: zone: us-east1-b and region :us-east1
gcloud compute project-info describe --project <project_id>

#set the default region/zone for all resources
gcloud config set compute/region us-east1
gcloud config set compute/zone   us-east1-b

#create instances 
instance_name="nucleus-jumphost"
gcloud compute instances create www1 \
  --image-family debian-9 \
  --image-project debian-cloud \
  --zone us-central1-a \
  --tags network-lb-tag \
  --metadata startup-script="#! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>www1</h1></body></html>' | tee /var/www/html/index.html"






