resource "aws_autoscaling_group" "slave" {
  availability_zones = ["${var.aws_region}a"]
  name = "dcos-SlaveServerGroup"
  desired_capacity = 5
  max_size = 5
  min_size = 5
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
