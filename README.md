# Rate-Limiting-with-Cloud-Armor_GSP975

🔁 Jalankan di beberapa terminal:

-----Terminal 1:

# Unduh semua file skrip setup

curl -LO https://raw.githubusercontent.com/ridhoreynaldo/Rate-Limiting-with-Cloud-Armor_GSP975/main/setup-1-env-and-templates.sh
curl -LO https://raw.githubusercontent.com/ridhoreynaldo/Rate-Limiting-with-Cloud-Armor_GSP975/main/setup-2-mig-health.sh
curl -LO https://raw.githubusercontent.com/ridhoreynaldo/Rate-Limiting-with-Cloud-Armor_GSP975/main/setup-3-backend-urlmap.sh
curl -LO https://raw.githubusercontent.com/ridhoreynaldo/Rate-Limiting-with-Cloud-Armor_GSP975/main/setup-4-proxy-forwarding-vm.sh

./setup-1-env-and-templates.sh

-----Terminal 2:

source .env && bash setup-2-mig-health.sh

source .env && ./setup-2-mig-health.sh

-----Terminal 3:

source .env && bash setup-3-backend-urlmap.sh

source .env && ./setup-3-backend-urlmap.sh

-----Terminal 4:

source .env && bash setup-4-proxy-forwarding-vm.sh

source .env && ./setup-4-proxy-forwarding-vm.sh
