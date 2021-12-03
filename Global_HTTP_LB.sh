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
gcloud compute instances create $instance_name \
  --image-family debian-9 \
  --image-project debian-cloud \
  --machine-type= f1-micro

#==================================================================================
# Task 2: Create a Kubernetes service cluster
# There is a limit to the resources you are allowed to create in your project. If you don't get the result you expected, delete the cluster before you create another cluster. If you don't, the lab might end and you might be blocked. In order to get your account unblocked, you will have to reach out to Qwiklabs Support.
# The team is building an application that will use a service running on Kubernetes. You need to:

# * Create a cluster (in the us-east1-b zone) to host the service.
# * Use the Docker container hello-app (gcr.io/google-samples/hello-app:2.0) as a place holder; the team will replace the container with their own work later.
# * Expose the app on port App port number .
#==================================================================================
cluster_name="nucleus-cluster1"
gcloud container clusters create $cluster_name
  #Get authentication credentials for the cluster
gcloud container clusters get-credentials $cluster_name
  #Deply an application
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0






