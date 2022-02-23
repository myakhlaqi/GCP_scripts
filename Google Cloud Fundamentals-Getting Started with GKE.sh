#Google Cloud Fundamentals: Getting Started with GKE

export MY_ZONE=us-central1-a
# create the kubernetes cluster
gcloud container clusters create webfrontend --zone $MY_ZONE --num-nodes 2

# check the kubernete version
kubectl version

#run and deploy a  nginx container on a container
kubectl create deploy nginx --image=nginx:1.17.10

#View the pod running the nginx container:
kubectl get pods

#Expose the nginx container to the Internet:
kubectl expose deployment nginx --port 80 --type LoadBalancer

#View the new service:
kubectl get services

#Scale up the number of pods running on your service:
kubectl scale deployment nginx --replicas 3
kubectl get pods



kubectl scale deployment nginx --replicas 3
kubectl get pods
