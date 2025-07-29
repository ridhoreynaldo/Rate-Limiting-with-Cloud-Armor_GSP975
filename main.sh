#!/bin/bash

# Styling
YELLOW=$(tput setaf 3)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Input dari user
read -p "${YELLOW}${BOLD}Enter the REGION1 (e.g., us-central1): ${RESET}" REGION1
read -p "${YELLOW}${BOLD}Enter the REGION2 (e.g., us-east1): ${RESET}" REGION2
read -p "${YELLOW}${BOLD}Enter the ZONE3 (e.g., us-central1-a): ${RESET}" ZONE3

# Proses
REGION3="${ZONE3%-*}"
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

# Save ke file .env
cat <<EOF > .env
export REGION1=$REGION1
export REGION2=$REGION2
export ZONE3=$ZONE3
export REGION3=$REGION3
export PROJECT_ID=$PROJECT_ID
export PROJECT_NUMBER=$PROJECT_NUMBER
EOF

echo -e "${BOLD}Variables saved to .env${RESET}"
