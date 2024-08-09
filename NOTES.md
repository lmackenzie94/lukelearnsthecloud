# Luke Learns The Cloud ☁️

**Sync with S3 bucket**

```bash
aws s3 sync . s3://lukelearnsthe.cloud
```

**Invalidate CloudFront cache**

```bash
aws cloudfront create-invalidation --distribution-id E2N6KLWY1L9MPP --paths "/*"
```
