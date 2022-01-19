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
instance_name="nucleus-jumphost-534"
gcloud compute instances create $instance_name \
  --image-family debian-9 \
  --image-project debian-cloud \
  --machine-type f1-micro

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
  #Expose app to port 8083 and create a loadbalancer for the container
kubectl expose deployment hello-app --type=LoadBalancer --port 8082
  #check the settings
kubectl get service
  #deleting the cluster in case of wrong configration
gcloud container clusters delete $cluster_name

#=============================================================================
# Task 3: Set up an HTTP load balancer
# You will serve the site via nginx web servers, but you want to ensure that the environment is fault-tolerant. Create an HTTP load balancer with a managed instance group of 2 nginx web servers. Use the following code to configure the web servers; the team will replace this with their own configuration later.

# There is a limit to the resources you are allowed to create in your project, so do not create more than 2 instances in your managed instance group. If you do, the lab might end and you might be banned.
# cat << EOF > startup.sh
# #! /bin/bash
# apt-get update
# apt-get install -y nginx
# service nginx start
# sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
# EOF
# Copied!
# You need to:

# 1- Create an instance template (nucleus-backend-template1).
# 2- Create a target pool (nucleus-target-pool1).
# 3- Create a managed instance group (nucleus-mig-group1).
# 4- Create a firewall rule named as Firewall rule to allow traffic (80/tcp) (nucleus-firewall-rule).
# 5- Create a health check.
# 6- Create a backend service, and attach the managed instance group.
# 7- Create a URL map, and target the HTTP proxy to route requests to your URL map.
# 8- Create a forwarding rule.
#=============================================================================

  # 1- Create an instance template (nucleus-backend-template1).
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' 
/var/www/html/index.nginx-debian.html
EOF


gcloud compute instance-templates create nucleus-backend-template1 \
  --metadata-from-file startup-script=startup.sh
  #  --network=default \
  #  --subnet=default \
  #  --tags=allow-health-check \
  #  --image-family=debian-9 \
  #  --image-project=debian-cloud \
   
  # 2- Create a target pool (nucleus-target-pool1).
gcloud compute target-pools managed create nucleus-target-pool1 

gcloud compute forwarding-rule create nginx-lb \
  --region us-east1 \
  --ports=80 \
  --target-pool nucleus-target-pool1

  # 3- Create a managed instance group (nucleus-mig-group1).
gcloud compute instance-groups managed create nucleus-mig-group1 \
   --template=nucleus-backend-template1 \
   --size=2 \
   --base-instance-name nginx \
   --target-pool nucleus-target-pool1
# 4- Create a firewall rule named as (allow-tcp-rule-402) Firewall rule to allow traffic (80/tcp) (nucleus-firewall-rule).
  gcloud compute firewall-rules create grant-tcp-rule-657 --allow tcp:80
# gcloud compute firewall-rules create allow-tcp-rule-402 \
#     --network=default \
#     --action=allow \
#     --direction=ingress \
#     --target-tags=allow-health-check \
#     --rules=tcp:80
  # 5- Create a health check.
gcloud compute health-checks create http http-basic-check \
    --port 80

gcloud compute instance-groups managed set-named-ports nucleus-mig-group1 --named-ports http:80

  # 6- Create a backend service, and attach the managed instance group (nucleus-web-backend-service).
gcloud compute backend-services create nucleus-web-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global
gcloud compute backend-services add-backend nucleus-web-backend-service \
    --instance-group nucleus-mig-group1 \
    --instance-group-zone us-east1-b \
    --global
  # 7- Create a URL map, and target the HTTP proxy to route requests to your URL map.
gcloud compute url-maps create nucleus-web-map-http \
    --default-service nucleus-web-backend-service

gcloud compute target-http-proxies create nucleus-http-lb-proxy \
    --url-map nucleus-web-map-http
  # 8- Create a forwarding rule.
gcloud compute forwarding-rules create nucleus-http-content-rule \
    --global \
    --target-http-proxy=nucleus-http-lb-proxy \
    --ports=80
    #--target-pool nucleus-target-pool1
# or run this command   
gcloud compute forwarding-rules create nucleus-http-content-rule \
    --global \
    --target-http-proxy=nucleus-http-lb-proxy \
    --ports=8080
    #--target-pool nucleus-target-pool1
    
     
