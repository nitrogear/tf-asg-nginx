variable "region" {
  description = "AWS region"
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "public_subnets" {
  description = "Subnets IDs"
  default     = []
}

variable "s3_bucket_name" {
  description = "S3 bucket for nginx"
  default     = ""
}

variable "nginx_count" {
  description = "Count of nginx instances"
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = ""
}

variable "key_name" {
  description = "EC2 keyname"
  default     = ""
}

variable "amis" {
  description = "Base AMI to launch the instances"
  type = "map"
  default = {
    "us-west-2" = "ami-c229c0a2"
  }
}