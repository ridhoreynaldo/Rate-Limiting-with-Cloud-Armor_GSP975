#!/bin/bash
source .env

# MIG
gcloud beta compute instance-groups managed create $REGION1-mig \
  --project=$PROJECT_ID \
  --region=$REGION1 \
  --template=projects/$PROJECT_ID/global/instanceTemplates/$REGION1-template \
  --size=1 && \
gcloud beta compute instance-groups managed set-autoscaling $REGION1-mig \
  --region=$REGION1 --mode=on --min-num-replicas=1 --max-num-replicas=5 --target-cpu-utilization=0.8

gcloud beta compute instance-groups managed create $REGION2-mig \
  --project=$PROJECT_ID \
  --region=$REGION2 \
  --template=projects/$PROJECT_ID/global/instanceTemplates/$REGION2-template \
  --size=1 && \
gcloud beta compute instance-groups managed set-autoscaling $REGION2-mig \
  --region=$REGION2 --mode=on --min-num-replicas=1 --max-num-replicas=5 --target-cpu-utilization=0.8

# Health Check
token=$(gcloud auth application-default print-access-token)
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{
    "name": "http-health-check",
    "type": "TCP",
    "tcpHealthCheck": { "port": 80 }
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/global/healthChecks"
