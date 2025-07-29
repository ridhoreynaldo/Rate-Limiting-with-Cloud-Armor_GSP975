#!/bin/bash
source .env
token=$(gcloud auth application-default print-access-token)

# Security Policy
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{
    "name": "default-security-policy-for-backend-service-http-backend",
    "rules": [
      {
        "action": "allow",
        "priority": 2147483647,
        "match": { "config": { "srcIpRanges": ["*"] }, "versionedExpr": "SRC_IPS_V1" }
      },
      {
        "action": "throttle",
        "priority": 2147483646,
        "description": "Default rate limiting rule",
        "match": { "config": { "srcIpRanges": ["*"] }, "versionedExpr": "SRC_IPS_V1" },
        "rateLimitOptions": {
          "conformAction": "allow",
          "exceedAction": "deny(403)",
          "enforceOnKey": "IP",
          "rateLimitThreshold": { "count": 500, "intervalSec": 60 }
        }
      }
    ]
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/securityPolicies"

sleep 20

# Backend Service
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{
    "name": "http-backend",
    "protocol": "HTTP",
    "portName": "http",
    "loadBalancingScheme": "EXTERNAL_MANAGED",
    "securityPolicy": "projects/'"$PROJECT_ID"'/global/securityPolicies/default-security-policy-for-backend-service-http-backend",
    "healthChecks": ["projects/'"$PROJECT_ID"'/global/healthChecks/http-health-check"],
    "backends": [
      { "group": "projects/'"$PROJECT_ID"'/regions/'"$REGION1"'/instanceGroups/'"$REGION1"'-mig" },
      { "group": "projects/'"$PROJECT_ID"'/regions/'"$REGION2"'/instanceGroups/'"$REGION2"'-mig" }
    ]
  }' \
  "https://compute.googleapis.com/compute/beta/projects/$PROJECT_ID/global/backendServices"

# URL Map
curl -X POST -H "Authorization: Bearer $token" -H "Content-Type: application/json" \
  -d '{"defaultService": "projects/'"$PROJECT_ID"'/global/backendServices/http-backend","name":"http-lb"}' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/urlMaps"
