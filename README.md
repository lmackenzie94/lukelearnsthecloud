# [Luke Learns The Cloud](https://lukelearnsthe.cloud) ☁️

[![Build and Deploy Website to S3 & CloudFront](https://github.com/lmackenzie94/lukelearnsthecloud/actions/workflows/deploy.yml/badge.svg?branch=main)](https://github.com/lmackenzie94/lukelearnsthecloud/actions/workflows/deploy.yml)

## Notes

- GitHub action deploys to S3 and invalidates CloudFront cache
- Docker Compose for local development
- AWS ECR for Docker image

### Build image

```bash
docker build -t lukelearnsthecloud:latest .
```

### Push image to ECR

```bash
aws sso login --profile admin

aws ecr get-login-password --region us-east-1 --profile admin | docker login --username AWS --password-stdin 021891593951.dkr.ecr.us-east-1.amazonaws.com

docker tag lukelearnsthecloud:latest 021891593951.dkr.ecr.us-east-1.amazonaws.com/lukelearnsthecloud:latest

docker push 021891593951.dkr.ecr.us-east-1.amazonaws.com/lukelearnsthecloud:latest
```

### Moving to Terraform (import existing resources)

1. Export AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)
2. Run `terraform init`
3. Create `imports.tf` and add all the resources you want to import (see `terraform/imports.tf`)
4. Run `terraform plan -generate-config-out=generated.tf` to generate the configuration code for the resources you want to import
5. Copy the generated code into `terraform/main.tf` and adjust as needed
6. Run `terraform plan` and ensure there are no major/breaking changes
7. Run `terraform apply`
   - The CloudFront distribution will take a while to create (~7 minutes) because it waits for it to deploy
   - To not wait, change `wait_for_deployment` to `false` on the `aws_cloudfront_distribution` resource
