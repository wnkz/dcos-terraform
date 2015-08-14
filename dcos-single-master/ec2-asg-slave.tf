resource "aws_autoscaling_group" "slave" {
  availability_zones = ["${var.aws_region}a"]
  name = "dcos-SlaveServerGroup"
  desired_capacity = "${var.slave_instance_count}"
  max_size = "${var.slave_instance_count}"
  min_size = "${var.slave_instance_count}"
  default_cooldown = 300
  health_check_grace_period = 0
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = ["${aws_subnet.private.id}"]
  launch_configuration = "${aws_launch_configuration.slave.name}"

  lifecycle {
      create_before_destroy = true
  }
}
