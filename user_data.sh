#!/bin/bash -xe

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
node -e "console.log('Running Node.js ' + process.version)"
sudo yum install git -y
git clone --no-checkout https://github.com/PaulEdson/DevOpsProj2
cd ./DevOpsProj2
git sparse-checkout init
git sparse-checkout set backend
git checkout master
cd backend
npm install

cd /var/lib/cloud/scripts/per-boot/
cat >> script.sh << EOF
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
cd /DevOpsProj2/backend
git pull
npm install
npm run start
EOF
chmod +x script.sh

cd /DevOpsProj2/backend
touch .env
cat >> .env << EOF
DB_HOST = "${aws_db_instance.default.address}"
DB_PORT = 5432
DB_USER = "postgres"
DB_PASSWORD = "y1ew1Fx3W0QwwGSD8EyQ"
DB_NAME = "private_db_pje"
SSL_BOOL = 0
EOF
npm run start