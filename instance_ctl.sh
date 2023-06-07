#!/bin/bash

# Function to stop EC2 instances
stop_instances() {
    aws ec2 stop-instances --instance-ids <instance-id1> <instance-id2> <instance-id3> ...
}

# Function to start EC2 instances
start_instances() {
    aws ec2 start-instances --instance-ids <instance-id1> <instance-id2> <instance-id3> ...
}

# Function to destroy EC2 instances
destroy_instances() {
    read -p "Are you sure you want to destroy the instances? (y/n): " answer
    if [[ $answer == "y" ]]; then
        aws ec2 terminate-instances --instance-ids <instance-id1> <instance-id2> <instance-id3> ...
    else
        echo "Destroy action canceled."
    fi
}

# Check the command-line arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: ./instance_ctl.sh [--stop|--start|--destroy]"
    exit 1
fi

# Execute the action based on the provided parameter
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
    *)
        echo "Invalid parameter. Usage: ./instance_ctl.sh [--stop|--start|--destroy]"
        exit 1
        ;;
esac
