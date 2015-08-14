variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "us-east-1"
}

variable "coreos_amis" {
    default = {
        ap-northeast-1 = "ami-22d27b22"
        ap-southeast-1 = "ami-0ef1f15c"
        ap-southeast-2 = "ami-2b2e6911"
        eu-central-1 = "ami-02211b1f"
        eu-west-1 = "ami-50f4b927"
        us-east-1 = "ami-6b1cd400"
        sa-east-1 = "ami-45a62a58"
        us-west-1 = "ami-bf8477fb"
        us-west-2 = "ami-f5a5a5c5"
    }
}

variable "nat_amis" {
    default = {
        ap-northeast-1 = "ami-55c29e54"
        ap-southeast-1 = "ami-b082dae2"
        ap-southeast-2 = "ami-996402a3"
        eu-central-1 = "ami-204c7a3d"
        eu-west-1 = "ami-3760b040"
        us-east-1 = "ami-4c9e4b24"
        sa-east-1 = "ami-b972dba4"
        us-west-1 = "ami-2b2b296e"
        us-west-2 = "ami-bb69128b"
    }
}

variable "vpc_subnet_range" {
  default = "10.0.0.0/16"
}

variable "private_subnet_range" {
  default = "10.0.0.0/22"
}

variable "public_subnet_range" {
  default = "10.0.4.0/22"
}

variable "master_instance_type" {
  default = "m4.xlarge"
}

variable "slave_instance_type" {
  default = "m4.xlarge"
}

variable "public_slave_instance_type" {
  default = "m4.xlarge"
}

variable "nat_instance_type" {
  default = "m3.medium"
}
