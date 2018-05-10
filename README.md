### Prerequisites

- Terraform
- AWS credentials

### Configuration

- [config.tf](config.tf) - remote terraform state if you want to store state on S3 (optional)
- [variables.tf](variables.tf) - variables:
  - region: AWS Region
  - azs: Availability zones
  - public_subnets: Public subnet CIDRs
  - public_subnets_names: Public subnet names
  - s3_bucket_name: S3 bucket name
  - nginx_count: Instance count
  - instance_type: EC2 Instance type
  - key_name: Key name for SSH into EC2 (key must exist before provision)
- Export `AWS_PROFILE` variable to use a non-default aws-cli profile

### Provision

Execute command to provision infrastructure:

```
AWS_PROFILE=<PROFILE_NAME> terraform validate
AWS_PROFILE=<PROFILE_NAME> terraform plan
AWS_PROFILE=<PROFILE_NAME> terraform apply
```