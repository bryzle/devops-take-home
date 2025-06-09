#!/bin/bash
set -e

AWS_REGION="us-east-1"
DOCKER_IMAGE="devops-takehome:latest"
TF_DIR="./terraform"

echo "Starting Terraform import process..."

# Security Group
SG_ID="sg-0fe5f4e70fa6622ec"
echo "Importing Security Group $SG_ID..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_security_group.devops_sg_v2 $SG_ID

# Launch Template
LT_ID="lt-08026b453e70cdf2a"
echo "Importing Launch Template $LT_ID..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_launch_template.devops_v2 $LT_ID

# ALB - get ARN from DNS name (you gave DNS, but import needs ARN)
ALB_DNS="devops-alb-v2-204987768.us-east-1.elb.amazonaws.com"
ALB_ARN=$(aws elbv2 describe-load-balancers --names devops-alb-v2 --region $AWS_REGION --query 'LoadBalancers[0].LoadBalancerArn' --output text)
echo "Found ALB ARN: $ALB_ARN"
echo "Importing ALB..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_lb.devops_alb_v2 $ALB_ARN

# Target Group (ARN given)
TG_ARN="arn:aws:elasticloadbalancing:us-east-1:042585259537:targetgroup/devops-tg-v2/3701e6a9fe4a763e"
echo "Importing Target Group $TG_ARN..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_lb_target_group.devops_tg_v2 $TG_ARN

# Listener - need to find ARN first
LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --region $AWS_REGION --query 'Listeners[0].ListenerArn' --output text)
echo "Found Listener ARN: $LISTENER_ARN"
echo "Importing Listener..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_lb_listener.http_v2 $LISTENER_ARN

# Auto Scaling Group - name already known
ASG_NAME="devops-asg-v2"
echo "Importing Auto Scaling Group $ASG_NAME..."
terraform import -var="docker_image=$DOCKER_IMAGE" -chdir=$TF_DIR aws_autoscaling_group.devops_asg_v2 $ASG_NAME

echo "All imports complete."
