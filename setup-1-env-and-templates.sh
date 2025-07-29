#!/bin/bash
set -euo pipefail

source .env

echo "🚀 Memulai pembuatan infrastruktur rate limiting..."

### 1. BUAT INSTANCE TEMPLATE + MIG + AUTOSCALER ###
echo "📦 Membuat instance template dan managed instance group..."

gcloud compute instance-templates create backend-template \
  --region="$REGION1" \
  --network=default \
  --subnet=default \
  --tags=http-server \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --metadata=startup-script='#! /bin/bash
    apt-get update
    apt-get install -y apache2
    a2ensite default-ssl
    a2enmod ssl
    service apache2 restart'

gcloud compute instance-groups managed create backend-group \
  --base-instance-name=backend \
  --template=backend-template \
  --size=1 \
  --region="$REGION1"

gcloud compute instance-groups managed set-autoscaling backend-group \
  --region="$REGION1" \
  --cool-down-period=90 \
  --max-num-replicas=3 \
  --min-num-replicas=1 \
  --target-cpu-utilization=0.6

### 2. HEALTH CHECK ###
echo "🩺 Membuat health check..."
if ! gcloud compute health-checks describe http-health-check &>/dev/null; then
  gcloud compute health-checks create http http-health-check \
    --port 80
fi

### 3. BACKEND SERVICE ###
echo "🔁 Membuat backend service dan menambahkan MIG..."

if ! gcloud compute backend-services describe http-backend --global &>/dev/null; then
  gcloud compute backend-services create http-backend \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-health-check \
    --global
fi

gcloud compute backend-services add-backend http-backend \
  --instance-group=backend-group \
  --instance-group-region="$REGION1" \
  --global

### 4. TUNGGU SAMPAI HEALTHY ###
echo "⏳ Menunggu MIG sehat sebelum lanjut..."
until gcloud compute backend-services get-health http-backend --global \
  --format="value(status.healthStatus[0].healthState)" | grep -q "HEALTHY"; do
  echo "🟡 Backend belum sehat... menunggu 5 detik"
  sleep 5
done
echo "✅ Backend HEALTHY!"

### 5. URL MAP + TARGET PROXY + FORWARDING RULE ###
echo "🌐 Membuat URL map, target proxy, dan forwarding rule..."

gcloud compute url-maps create http-lb \
  --default-service=http-backend

gcloud compute target-http-proxies create http-lb-target-proxy \
  --url-map=http-lb

gcloud compute forwarding-rules create http-lb-forwarding-rule \
  --global \
  --target-http-proxy=http-lb-target-proxy \
  --ports=80 \
  --address=IP_ADDRESS

### 6. VM CLIENT (SIEGE) ###
echo "🧪 Membuat VM untuk pengujian (siege)..."
if ! gcloud compute instances describe siege-vm \
    --zone="$ZONE2" &>/dev/null; then
  gcloud compute instances create siege-vm \
    --zone="$ZONE2" \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server \
    --metadata=startup-script='#! /bin/bash
      apt-get update
      apt-get install -y siege'
fi

echo "🎉 Selesai! Load balancer kamu seharusnya sudah aktif. Cek IP forwarding-nya:"
gcloud compute forwarding-rules describe http-lb-forwarding-rule --global \
  --format="get(IPAddress)"
