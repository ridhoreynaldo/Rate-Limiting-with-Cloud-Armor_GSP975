#!/bin/bash
source .env

echo "🕒 Menunggu backend service dan health check tersedia..."
until gcloud compute backend-services describe http-backend --global &>/dev/null; do
  echo "⏳ Menunggu http-backend..."
  sleep 5
done

until gcloud compute health-checks describe http-health-check &>/dev/null; do
  echo "⏳ Menunggu http-health-check..."
  sleep 5
done

echo "🌐 Membuat URL map dan target proxy..."
gcloud compute url-maps create http-lb \
  --default-service=http-backend

gcloud compute target-http-proxies create http-lb-target-proxy \
  --url-map=http-lb

gcloud compute forwarding-rules create http-content-rule \
  --global \
  --target-http-proxy=http-lb-target-proxy \
  --ports=80
