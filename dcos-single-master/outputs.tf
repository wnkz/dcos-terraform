output "Mesos Master" {
  value = "${aws_elb.default.dns_name}"
}

output "Public slaves" {
  value = "${aws_elb.public_slave.dns_name}"
}
