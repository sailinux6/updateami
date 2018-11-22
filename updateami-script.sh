#!/bin/bash

# This script will test the updates on packer ami image

# create temporary ec2 instance using packer ami image
terraform init ./terraform
terraform apply -auto-approve ./terraform

sleep 60

hostip=$(terraform output ec2_public_ip)
amiid=$(terraform output packer_ami_id)
user=centos

# check for the updates on packer ami
chmod 400 key/tmpkey
ssh -i ./key/tmpkey -o StrictHostKeyChecking=no $user@$hostip "sudo yum check-update" > /dev/null

# set the variable if updates found
if [ $? -eq 0 ]
  then
    echo "No updates found"
	export updateami=no
        updateami=no
  else
    echo "Update found on image"
	export updateami=yes
         updateami=yes
fi

# destroy the ec2 instance
terraform destroy -auto-approve ./terraform
sleep 10

# Trigger another packer job from here to create ami

if [ updateami == 'yes' ]
  then
    echo "updating packer image"
	export amiid=$amiid
	packer build ./packer/packer.json
	
	sleep 15
    # destroying old ami
    aws ec2 deregister-image --image-id $amiid
fi

echo "new ami updated successfully..."


