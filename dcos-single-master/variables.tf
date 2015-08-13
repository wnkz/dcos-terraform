variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
    description = "AWS region to launch servers."
    default = "us-east-1"
}

# CoreOS
variable "coreos_amis" {
    default = {
        us-east-1 = "ami-6b1cd400"
    }
}

# NATAmi
variable "nat_amis" {
    default = {
        us-east-1 = "ami-4c9e4b24"
    }
}
