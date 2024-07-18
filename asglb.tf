resource "aws_launch_configuration" "ansible" {
  name            = "terraansi"
  image_id        = var.amiid
  instance_type   = var.instancetype
  security_groups = [aws_security_group.ansible_server.id]
  key_name        = "qwerty"

}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.ansible.name
  max_size             = 2
  min_size             = 2
  desired_capacity     = 2
  // availability_zones = ["eu-cental-1a" , "eu-central-1b"]
  vpc_zone_identifier = [var.subnet, var.subnet1]

}

resource "aws_lb" "lb" {
  name               = "asglb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.ansible_server.id]
  subnets            = [var.subnet, var.subnet1]
  tags = {
    Name = "lb"
  }
}

resource "aws_lb_target_group" "target" {
  name        = "targetlb"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = var.vpcid
  target_type = "instance"
  health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_autoscaling_attachment" "asgtg" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.target.arn

}