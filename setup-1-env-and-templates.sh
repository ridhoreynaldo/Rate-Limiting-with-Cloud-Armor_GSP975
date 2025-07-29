#!/bin/bash
echo "Setting project and environment variables..."

read -p "Masukkan PROJECT_ID: " PROJECT_ID
read -p "Masukkan REGION1: " REGION1
read -p "Masukkan REGION2: " REGION2
read -p "Masukkan ZONE1: " ZONE1
read -p "Masukkan ZONE2: " ZONE2

cat <<EOF > .env
export PROJECT_ID=$PROJECT_ID
export REGION1=$REGION1
export REGION2=$REGION2
export ZONE1=$ZONE1
export ZONE2=$ZONE2
EOF

echo "Environment disimpan ke .env"
