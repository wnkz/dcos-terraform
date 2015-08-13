resource "aws_autoscaling_group" "public_slave" {
  availability_zones = ["us-east-1a"]
  name = "dcos-PublicSlaveServerGroup"
  desired_capacity = 1
  max_size = 1
  min_size = 1
  default_cooldown = 300
  health_check_grace_period = 0
  health_check_type = "EC2"
  force_delete = true
  vpc_zone_identifier = ["${aws_subnet.public.id}"]
  launch_configuration = "${aws_launch_configuration.public_slave.name}"
  load_balancers = ["${aws_elb.public_slave.name}"]

  lifecycle {
      create_before_destroy = true
  }
}
