#!/bin/bash
source .env

echo "🕒 Menunggu URL map dan proxy tersedia..."
until gcloud compute url-maps describe http-lb --global &>/dev/null; do
  echo "⏳ Menunggu urlMap http-lb..."
  sleep 5
done

until gcloud compute target-http-proxies describe http-lb-target-proxy --global &>/dev/null; do
  echo "⏳ Menunggu target proxy..."
  sleep 5
done

echo "🚀 Membuat VM penguji (siege)..."
gcloud compute instances create siege-vm \
  --zone=$ZONE2 \
  --tags=http-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt-get update
    sudo apt-get install -y siege'
