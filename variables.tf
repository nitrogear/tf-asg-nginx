variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "azs" {
  description = "Availability zones"
  default     = ["us-west-2a","us-west-2b","us-west-2c"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs"
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_names" {
  description = "Public subnet names"
  default     = ["nginx a", "nginx b","nginx c"]
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  default     = "nitrogear-asg-nginx"
}

variable "nginx_count" {
  description = "Instance count"
  default     = "3"
}

variable "instance_type" {
  description = "EC2 Instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for SSH into EC2"
  default     = "nginx"
}
