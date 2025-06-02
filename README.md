# DevOps Take-Home Assessment

## Overview

This project demonstrates a complete deployment pipeline for a Rust backend server, showcasing containerization, CI/CD pipeline creation, infrastructure scalability, testing, and code review practices.

## Containerization

The Rust backend is containerized using a multi-stage Dockerfile to optimize for size and efficiency. The final image is based on a minimal Debian image.

## CI/CD Pipeline

The CI/CD pipeline is configured using GitHub Actions. It includes the following steps:
- Build and test the Rust application.
- Build and publish the Docker container to Docker Hub.
- Deploy the Docker container using Terraform.

## Scalability Strategy

The deployment is configured to run on an AWS EC2 instance. The setup can be scaled by adjusting the instance type or adding more instances through Terraform configuration.

## Testing Approach

Automated tests are included in the pipeline using `cargo test`. These tests ensure the correctness of the application before deployment.

## Code Review Practices

Recommended code review process:
- Structure reviews to focus on security, readability, and efficiency.
- Prioritize critical areas such as authentication, data handling, and error management.
- Use automated code review tools like `clippy` for Rust to catch common issues.

## Running the Pipeline

1. **Set up Docker Hub Credentials:**
   - Go to your GitHub repository settings, navigate to "Secrets and variables" > "Actions", and add the following secrets:
     - `DOCKER_HUB_USERNAME`: Your Docker Hub username.
     - `DOCKER_HUB_ACCESS_TOKEN`: A Docker Hub access token.

2. **Terraform Setup:**
   - Ensure you have an AWS account and set up AWS credentials as GitHub secrets:
     - `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
     - `TF_API_TOKEN`: Terraform API token for authentication.

3. **Deploying with Terraform:**
   - The Terraform configuration is located in `terraform/main.tf`. It provisions an EC2 instance and runs the Docker container.

4. **Trigger the Pipeline:**
   - Push changes to the `main` branch to trigger the CI/CD pipeline.

## Infrastructure Configuration

The Terraform configuration is located in `terraform/main.tf`. It defines the infrastructure setup and deployment strategy.
