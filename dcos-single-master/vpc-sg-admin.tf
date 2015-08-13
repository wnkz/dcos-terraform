resource "aws_security_group" "admin" {
    name        = "dcos-AdminSecurityGroup"
    description = "Enable admin access to servers"
    vpc_id      = "${aws_vpc.dcos.id}"

    tags {
        "Environment" = "dcos"
    }
}

resource "aws_security_group_rule" "admin1" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.admin.id}"
}
