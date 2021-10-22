# Next JS Frontend

Terraform Module to use together with [Serverless-NextJS](https://github.com/serverless-nextjs/serverless-next.js). The main goal is to configure a Cloudfront distribution with a Bucket, Certificate and DNS Record. The rest is managed by the nextjs component. 

## What does he do?

1. Creates a bucket with the name `subdomain-domain-com`
1. Creates a Cloudfront distribution.
1. Generates certificates and validates with DNS records.
1. Ignores for changes on nextjs component.

## How to use?
Copy and paste on your Terraform source:
```
module "serverless_nextjs" {
  source      = "graphnode-technologies/nextjs-serverless/aws"
  version     = "~> 1.0"
  domain_name = var.domain_name
  zone_id     = var.zone_id
}
```

then run `terraform init`, `terraform plan` and `terraform apply`.