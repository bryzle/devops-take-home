#!/bin/bash
set -e

AWS_REGION="us-east-1"
TF_DIR="./terraform"

echo "Starting Terraform import process..."

# Security Group
SG_ID="sg-0fe5f4e70fa6622ec"
echo "Importing Security Group $SG_ID..."
(cd $TF_DIR && terraform import aws_security_group.devops_sg_v2 $SG_ID)

# Launch Template
LT_ID="lt-08026b453e70cdf2a"
echo "Importing Launch Template $LT_ID..."
(cd $TF_DIR && terraform import aws_launch_template.devops_v2 $LT_ID)

# ALB ARN - fetch from ALB name
ALB_NAME="devops-alb-v2"
ALB_ARN=$(aws elbv2 describe-load-balancers --names $ALB_NAME --region $AWS_REGION --query 'LoadBalancers[0].LoadBalancerArn' --output text)
echo "Found ALB ARN: $ALB_ARN"
echo "Importing ALB..."
(cd $TF_DIR && terraform import aws_lb.devops_alb_v2 $ALB_ARN)

# Target Group ARN (given)
TG_ARN="arn:aws:elasticloadbalancing:us-east-1:042585259537:targetgroup/devops-tg-v2/3701e6a9fe4a763e"
echo "Importing Target Group $TG_ARN..."
(cd $TF_DIR && terraform import aws_lb_target_group.devops_tg_v2 $TG_ARN)

# Listener ARN - fetch using ALB ARN
LISTENER_ARN=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --region $AWS_REGION --query 'Listeners[0].ListenerArn' --output text)
echo "Found Listener ARN: $LISTENER_ARN"
echo "Importing Listener..."
(cd $TF_DIR && terraform import aws_lb_listener.http_v2 $LISTENER_ARN)

# Auto Scaling Group
ASG_NAME="devops-asg-v2"
echo "Importing Auto Scaling Group $ASG_NAME..."
(cd $TF_DIR && terraform import aws_autoscaling_group.devops_asg_v2 $ASG_NAME)

echo "All imports complete."
