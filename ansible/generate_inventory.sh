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
cat > inventory_check.ini <<EOL
[frontend]
frontend-instance ansible_host=${FRONTEND_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/.ssh/vijaya-key-cloudwatch.pem

[backend]
backend-instance ansible_host=${BACKEND_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/.ssh/vijaya-key-cloudwatch.pem

[db]
db-instance ansible_host=${DB_IP} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/.ssh/vijaya-key-cloudwatch.pem
EOL

echo "✅ Inventory file generated successfully:"
