# Luke Learns The Cloud ☁️

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
