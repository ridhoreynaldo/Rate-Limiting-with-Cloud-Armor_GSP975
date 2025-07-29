#!/bin/bash
source .env

echo "🛠 Membuat Instance Template dan Managed Instance Group..."

gcloud compute instance-templates create web-template \
  --region=$REGION1 \
  --network=default \
  --tags=http-server \
  --metadata=startup-script='#!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    echo "Server: $(hostname)" | sudo tee /var/www/html/index.html'

gcloud compute instance-groups managed create web-mig \
  --base-instance-name web \
  --template=web-template \
  --size=2 \
  --region=$REGION1

echo "🩺 Membuat health check dan backend service..."
gcloud compute health-checks create http http-health-check

gcloud compute backend-services create http-backend \
  --protocol=HTTP \
  --health-checks=http-health-check \
  --global

gcloud compute backend-services add-backend http-backend \
  --instance-group=web-mig \
  --instance-group-region=$REGION1 \
  --global
