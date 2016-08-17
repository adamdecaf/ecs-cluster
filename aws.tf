variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "${var.region}"

  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

# todo: multiple regions
variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "key_name" {
  description = "The aws ssh key name."
  default = "ecs"
}

variable "key_file" {
  description = "The ssh public key for using with the cloud provider."
  default = ""
}

# networking
# todo: create a vpc
variable "vpc_id" {
  default = "vpc-46685a23"
}

variable "subnet_ids" {
  description = "comma separated list of subnet ids"
  default = "subnet-0af1ce30"
}

variable "availability_zones" {
  description = "The availability zones"
  default = "us-east-1b"
}

# instance variables
variable "amis" {
  default = {
    us-east-1 = "ami-a1fa1acc"
  }
}

variable "instance_type" {
  default = "t2.small"
}
