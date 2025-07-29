#!/bin/bash

# Set style
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "Please set the below values correctly"
read -p "${YELLOW}${BOLD}Enter the REGION1: ${RESET}" REGION1
read -p "${YELLOW}${BOLD}Enter the REGION2: ${RESET}" REGION2
read -p "${YELLOW}${BOLD}Enter the ZONE3: ${RESET}" ZONE3

export REGION3="${ZONE3%-*}"
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# Save env
cat <<EOF > .env
export REGION1=$REGION1
export REGION2=$REGION2
export ZONE3=$ZONE3
export REGION3=$REGION3
export PROJECT_ID=$PROJECT_ID
export PROJECT_NUMBER=$PROJECT_NUMBER
EOF

# Auth & API
gcloud auth list
gcloud services enable osconfig.googleapis.com

# Firewall
gcloud compute firewall-rules create default-allow-http \
  --project=$PROJECT_ID \
  --direction=INGRESS --priority=1000 --network=default \
  --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud compute firewall-rules create default-allow-health-check \
  --project=$PROJECT_ID \
  --direction=INGRESS --priority=1000 --network=default \
  --action=ALLOW --rules=tcp:80 \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 --target-tags=http-server

# Instance templates
gcloud compute instance-templates create $REGION1-template \
  --project=$PROJECT_ID --machine-type=e2-medium \
  --region=$REGION1 --tags=http-server \
  --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true \
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,size=10,type=pd-balanced

gcloud compute instance-templates create $REGION2-template \
  --project=$PROJECT_ID --machine-type=e2-medium \
  --region=$REGION2 --tags=http-server \
  --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh,enable-oslogin=true \
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,size=10,type=pd-balanced
