resource "aws_security_group" "admin" {
    name        = "dcos-AdminSecurityGroup"
    description = "Enable admin access to servers"
    vpc_id      = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "allow_all_to_admin" {
    type = "ingress"
    from_port = 0
    to_port = 65535
    protocol = "-1"
    cidr_blocks = ["${var.admin_location}"]

    security_group_id = "${aws_security_group.admin.id}"
}


resource "aws_security_group_rule" "admin_outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.admin.id}"
}
