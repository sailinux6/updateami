#!/bin/bash

# This script will test the updates on packer ami image
whoami
# create temporary ec2 instance using packer ami image
terraform init ./terraform
terraform apply -auto-approve ./terraform

# Checking Status of terraform command
 
if [ $? -ne 0 ]; then exit 1; fi

sleep 60

hostip=$(terraform output ec2_public_ip)
amiid=$(terraform output packer_ami_id)
user=centos

# check for the updates on packer ami
chmod 400 key/tmpkey
ssh -i ./key/tmpkey -o StrictHostKeyChecking=no $user@$hostip "sudo yum check-update"
sshstat=$?

# set the variable if updates found
if [ $sshstat -eq 100 ]
  then
    echo "Update found on image"
    updateami=yes
elif [ $sshstat -eq 0 ]
  then
	echo "No updates found"
    updateami=no
	
else
   echo "issue with ssh connection"
   exit 1 
fi

# destroy the ec2 instance
echo "destroying testami ec2 instance..."
terraform destroy -auto-approve ./terraform
sleep 10

echo "newami=no"
# Trigger another packer job from here to create ami

if [ $updateami == 'yes' ]
  then
    echo "updating packer image..."
	echo "$amiid"
	export base_ami=$amiid
    sudo /usr/bin/packer build -var "aws_access_key=$AWS_ACCESS_KEY_ID"  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" -var "base_ami=$amiid" ./packer/packer.json
	
    
    if [ $? -eq 0 ]
      then
	    echo "new ami updated successfully"
		#echo "destroying previous ami image..."
        #sleep 15
        # destroying old ami
        #aws ec2 deregister-image --image-id $base_ami
		#echo "$base_ami destroyed successfully"
		mail -s 'Notify: Packer AMI updated successfully.' sailinux6@gmail.com << EOF
        New Packer AMI updated successfully. Please check from the below url.
        ${BUILD_URL}
EOF
    else
	  echo "error in packer build..."
	  exit 1
    fi
	
fi