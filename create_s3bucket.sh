#!/bin/bash

# Check if custombucketname is set
if [ -z "eventsmanagername" ]; then
  echo "Error: 'custombucketname' is not set. Please set it before running the script."
  exit 1
fi

# Function to check if the bucket name is valid and available
function is_bucket_name_available {
  local bucket_name=$1
  aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo 0  # Bucket exists
  else
    echo 1  # Bucket is available
  fi
}

# Main script
while true; do
  # Use the predefined custombucketname
  bucket_name=eventsmanagername
  echo "Attempting to create bucket: $bucket_name"

  # Check if the bucket name is available
  if [ "$(is_bucket_name_available "$bucket_name")" -eq 1 ]; then
    # Get the configured AWS region
    region=$(aws configure get region)

    # Check if the region is us-east-1
    if [ "$region" == "us-east-1" ]; then
      # Create the bucket without LocationConstraint
      aws s3api create-bucket --bucket "$bucket_name"
    else
      # Create the bucket with LocationConstraint for other regions
      aws s3api create-bucket --bucket "$bucket_name" --create-bucket-configuration LocationConstraint="$region"
    fi

    if [ $? -eq 0 ]; then
      # Disable Block Public Access
      aws s3api put-public-access-block --bucket "$bucket_name" \
        --public-access-block-configuration \
        BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

      echo "S3 bucket '$bucket_name' created with Block All Public Access disabled."
      break
    else
      echo "Error creating bucket. Retrying..."
    fi
  else
    echo "Bucket name '$bucket_name' is already taken. Please set a unique name for 'custombucketname'."
    exit 1
  fi
done