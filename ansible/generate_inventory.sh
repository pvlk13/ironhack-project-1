#!/bin/bash

#Go to terraform folder
SSH_CONFIG="/home/ec2-user/.ssh/config"

cd /home/ec2-user/ironhack-project/terraform
TF_OUTPUT_FILE="../terraform/tf_output.json" 
KEY_VALUE="/home/ec2-user/.ssh/vijaya-key-cloudwatch.pem"

#Get values from tf_state in terraform
DB_IP=$(jq -r '.db_private_ip.value' $TF_OUTPUT_FILE)
BACKEND_IP=$(jq -r '.backend_private_ip.value' $TF_OUTPUT_FILE)
FRONTEND_IP=$(jq -r '.frontend_public_ip.value' $TF_OUTPUT_FILE)

#Back in ansible folder to populate inventory.ini
cd /home/ec2-user/ironhack-project/ansible

#create .ssh/config
cat >>"$SSH_CONFIG"<<EOL
Host frontend-instance
   HostName $FRONTEND_IP
   User     ec2-user
   IdentityFile $KEY_VALUE
Host backend-instance
   HostName $BACKEND_IP
   User     ec2-user
   IdentityFile $KEY_VALUE
Host db-instance
   HostName $DB_IP
   User     ec2-user
   IdentityFile $KEY_VALUE
EOL
echo "✅  SSH config updated!"

#create inventory
cat > inventory.ini <<EOL

[FRONTEND]
frontend-instance

[db]
db-instance

[backend]
backend-instance
EOL


echo "✅ Inventory file generated successfully:"
