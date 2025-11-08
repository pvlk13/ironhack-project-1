#!/bin/bash

#Go to terraform folder
TF_OUTPUT_FILE="../terraform/tf_output.json"
KEY_VALUE="/Users/anilyadav/Downloads/vijaya-key-cloudwatch.pem"

#Get values from tf_state in terraform
DB_IP=$(jq -r '.db_private_ip.value' $TF_OUTPUT_FILE)
BACKEND_IP=$(jq -r '.backend_private_ip.value' $TF_OUTPUT_FILE)
FRONTEND_IP=$(jq -r '.frontend_public_ip.value' $TF_OUTPUT_FILE)

#Back in ansible folder to populate inventory.ini
ANSIBLE_DIR="/Users/anilyadav/projects/ironhack-project-1/ansible"
SSH_CONFIG="~/.ssh/config"

#!/bin/bash

# Define SSH config path (use $HOME to expand properly)
SSH_CONFIG="$HOME/.ssh/config"

# Define all.yml to get dynamic ip's into yml's
GRP_CONFIG="group_vars/all.yml"

# Make sure the .ssh directory exists
mkdir -p "$(dirname "$SSH_CONFIG")"
chmod 700 "$(dirname "$SSH_CONFIG")"

# Replace contents of config file (overwrite)
cat > "$SSH_CONFIG" <<EOL
Host frontend-instance
   HostName ${FRONTEND_IP}
   User     ec2-user
   IdentityFile ${KEY_VALUE}

Host backend-instance
   HostName ${BACKEND_IP}
   User     ec2-user
   ProxyJump frontend-instance
   IdentityFile ${KEY_VALUE}

Host db-instance
   HostName ${DB_IP}
   User     ec2-user
   ProxyJump frontend-instance
   IdentityFile ${KEY_VALUE}
EOL

# Secure the config file
chmod 600 "$SSH_CONFIG"

echo "✅ SSH config created and updated at: $SSH_CONFIG"

#create inventory
cat > inventory.ini <<EOL

[frontend]
frontend-instance

[db]
db-instance

[backend]
backend-instance
EOL

#create all.yml in group_vars
cat > $GRP_CONFIG <<EOL
backend_ip: $BACKEND_IP
db_ip: $DB_IP
EOL
echo "✅group_vars is created"
echo "✅ Inventory file generated successfully:"


