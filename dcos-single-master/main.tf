# Configure the AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_vpc" "dcos" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags {
        "Name" = "DCOS"
        "Environment" = "dcos"
    }
}
resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.dcos.id}"

    tags {
        Name = "DCOS"
    }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name = "ec2.internal"
    domain_name_servers = ["AmazonProvidedDNS"]

    tags {
        Name = "DCOS"
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = "${aws_vpc.dcos.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "aws_subnet" "public" {
    vpc_id = "${aws_vpc.dcos.id}"
    cidr_block = "10.0.4.0/22"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.dcos.id}"
    cidr_block = "10.0.0.0/22"
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = false

    tags {
        "Environment" = "dcos"
    }
}
