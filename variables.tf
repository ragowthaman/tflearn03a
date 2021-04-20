variable "aws_region" {type = string}
variable "os_image_name" {type = string}
variable "vpc_cidr_block" {type = string}
variable "subnet_cidr_block_pub" { type = string}
variable "subnet_cidr_block_pvt" { type = string}
variable "avail_zone" {type = string}
variable "env_prefix" {}
variable "instance_type" {}
