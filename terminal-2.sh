#!/bin/bash
source .env

# Contoh: buat firewall dan instance template REGION1
gcloud compute --project=$PROJECT_ID firewall-rules create default-allow-http \
  --direction=INGRESS --priority=1000 --network=default \
  --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server

gcloud compute instance-templates create $REGION1-template --project=$PROJECT_ID \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh \
  --region=$REGION1 --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,size=10,type=pd-balanced
