#!/bin/bash
source .env
token=$(gcloud auth application-default print-access-token)

# Target Proxies
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{"name":"http-lb-target-proxy","urlMap":"projects/'"$PROJECT_ID"'/global/urlMaps/http-lb"}' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/targetHttpProxies"

# Forwarding Rule IPv4
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{
    "name": "http-lb-forwarding-rule",
    "IPProtocol": "TCP",
    "portRange": "80",
    "target": "projects/'"$PROJECT_ID"'/global/targetHttpProxies/http-lb-target-proxy",
    "loadBalancingScheme": "EXTERNAL_MANAGED",
    "networkTier": "PREMIUM"
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/global/forwardingRules"

# Siege VM
gcloud compute instances create siege-vm \
  --project=$PROJECT_ID --zone=$ZONE3 \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,subnet=default \
  --metadata=enable-osconfig=TRUE,enable-oslogin=true \
  --create-disk=auto-delete=yes,boot=yes,image=projects/debian-cloud/global/images/debian-12-bookworm-v20250311,size=10,type=pd-balanced

# Install siege
gcloud compute ssh --zone "$ZONE3" "siege-vm" --project "$PROJECT_ID" \
  --command "sudo apt-get -y install siege" --quiet
