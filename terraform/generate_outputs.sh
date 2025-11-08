	#!/bin/bash
	terraform apply -auto-approve
	terraform output -json > tf_output.json
	echo "✅ tf_output.json generated successfully"

