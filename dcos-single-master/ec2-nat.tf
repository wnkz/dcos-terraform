resource "aws_instance" "nat" {
    ami = "${lookup(var.nat_amis, var.aws_region)}"
    availability_zone = "${var.aws_region}a"
    ebs_optimized = false
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.public.id}"
    vpc_security_group_ids = ["${aws_security_group.slave.id}", "${aws_security_group.admin.id}", "${aws_security_group.master.id}"]
    associate_public_ip_address = true
    source_dest_check = false

    root_block_device {
        volume_type = "standard"
        volume_size = 8
        delete_on_termination = true
    }

    tags {
        "Name" = "nat"
        "Environment" = "dcos"
    }
}
