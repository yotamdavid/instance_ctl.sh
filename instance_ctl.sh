#!/bin/bash

# Function to stop instances
stop_instances() {
  echo "Stopping all running instances..."
  aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
}

# Function to start instances
start_instances() {
  echo "Starting all stopped instances..."
  aws ec2 start-instances --instance-ids $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --query "Reservations[].Instances[].InstanceId" --output text)
}

# Function to destroy instances
destroy_instances() {
  read -p "Are you sure you want to destroy all instances? (y/n) " confirm
  if [[ $confirm == "y" ]]; then
    echo "Destroying all instances..."
    aws ec2 terminate-instances --instance-ids $(aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text)
  else
    echo "Aborted."
  fi
}

# Function to create AMI
create_ami() {
  instance_id=$1
  ami_name=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=key,Values=Name" --query "Tags[0].Value" --output text)
  ami_name="${ami_name}-AMI"
  
  echo "Creating AMI for instance: $instance_id"
  aws ec2 deregister-image --image-ids $(aws ec2 describe-images --filters "Name=name,Values=$ami_name" --query "Images[0].ImageId" --output text) > /dev/null 2>&1
  
  aws ec2 create-image --instance-id $instance_id --name $ami_name --description "AMI for instance: $instance_id" > /dev/null
  echo "Created AMI: $ami_name"
}

# Main script
if [[ $# -eq 0 ]]; then
  echo "Usage: ./instance_ctl.sh [--stop|--start|--destroy|--create_ami INSTANCE_ID]"
  exit 1
fi

case $1 in
  --stop)
    stop_instances
    ;;
  --start)
    start_instances
    ;;
  --destroy)
    destroy_instances
    ;;
  --create_ami)
    if [[ $# -eq 2 ]]; then
      create_ami $2
    else
      echo "Usage: ./instance_ctl.sh --create_ami INSTANCE_ID"
    fi
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac
