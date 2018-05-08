resource "aws_security_group" "ssh_http" {
  name   = "ssh-http"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "nginx_launch_configuration" {
  image_id             = "${lookup(var.amis,var.region)}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.nginx_profile.id}"
  security_groups      = ["${aws_security_group.ssh_http.id}"]
  key_name             = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
  user_data =
<<EOF
#cloud-config
repo_update: true
repo_upgrade: all

packages:
 - nginx

runcmd:
 - service nginx start
 - chkconfig nginx on
EOF
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx-profile"
  role = "${aws_iam_role.nginx_role.name}"
}

resource "aws_autoscaling_group" "nginx_autoscaling_group" {
  name                 = "nginx-asg"
  launch_configuration = "${aws_launch_configuration.nginx_launch_configuration.id}"
  vpc_zone_identifier  = ["${var.public_subnets}"]
  min_size             = "${var.nginx_count}"
  max_size             = "${var.nginx_count}"

  tag {
    key = "name"
    value = "nginx-aws-autoscaling-group"
    propagate_at_launch = true
  }
}

resource "aws_s3_bucket" "nginx_s3" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"

  tags {
    Name = "nginx"
  }
}

resource "aws_iam_role" "nginx_role" {
  name               = "nginx-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "nginx_policy" {
  name   = "nginx-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "nginx_attachment" {
  name       = "nginx-attachment"
  roles      = ["${aws_iam_role.nginx_role.name}"]
  policy_arn = "${aws_iam_policy.nginx_policy.arn}"
}