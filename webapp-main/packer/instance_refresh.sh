#!/bin/bash
set -e

launch_version=$(aws ec2 describe-launch-templates \
  --query 'sort_by(LaunchTemplates, &CreateTime)[-1].LatestVersionNumber' \
  --output text)

if [ "$launch_version" == "None" ]; then
    echo "No launch template available to update"
    exit 1
fi

ami_id=$(aws ec2 describe-images \
  --executable-users self \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)

asg_name=$(aws autoscaling describe-auto-scaling-groups \
  --query 'sort_by(AutoScalingGroups, &CreatedTime)[-1].AutoScalingGroupName' \
  --output text)

launch_template_id=$(aws ec2 describe-launch-templates \
  --query 'sort_by(LaunchTemplates, &CreateTime)[-1].LaunchTemplateId' \
  --output text)

aws ec2 create-launch-template-version \
  --launch-template-id "$launch_template_id" \
  --source-version "$launch_version" \
  --launch-template-data "{\"ImageId\":\"$ami_id\"}"

current_version=$(aws ec2 describe-launch-templates \
  --query 'sort_by(LaunchTemplates, &CreateTime)[-1].LatestVersionNumber' \
  --output text)

aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name "$asg_name" \
  --launch-template "LaunchTemplateId=$launch_template_id,Version=$current_version"

inst_refresh_id=$(aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$asg_name" \
  --query "InstanceRefreshId" \
  --output text)


while true; do
    refresh_status=$(aws autoscaling describe-instance-refreshes \
      --auto-scaling-group-name "$asg_name" \
      --instance-refresh-ids "$inst_refresh_id" \
      --query 'InstanceRefreshes[0].Status' \
      --output text)

    if [ "$refresh_status" == "Successful" ]; then
    echo "Instance Refresh completed successfully!"
    break
    elif [ "$refresh_status" == "Failed" ]; then
    echo "Instance Refresh failed."
    exit 1
     else
    echo "Instance Refresh is still in progress. Checking again in 30 seconds..."
    sleep 30
    fi
done



