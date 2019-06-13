# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}


# Networking
resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "main_subnet_a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.31.32.0/20"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "main_subnet_b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.31.0.0/20"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

# \ Networking

# EC2

resource "aws_security_group" "security_group_web" {
  name = "security_group_web"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_alb" "lb_web" {
  name = "lb-web"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    "${aws_security_group.security_group_web.id}"]
  subnets = [
    "${aws_subnet.main_subnet_a.id}",
    "${aws_subnet.main_subnet_b.id}"
  ]
}


resource "aws_alb_target_group" "target_group_web" {
  name = "target-group-web"
  target_type = "ip"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"
  depends_on = [
    "aws_alb.lb_web"]
}
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.lb_web.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.target_group_web.arn}"
    type = "forward"
  }
}

# \ EC2

# ECS

resource "aws_ecr_repository" "ecr_webserver" {
  name = "ecr_webserver"
}

resource "aws_ecs_cluster" "ecs_cluster_web" {
  name = "ecs_cluster_web"
}

data "template_file" "ecs_task_container_definitions" {
  template = "${file("container-definition.json")}"
  vars = {
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/ecr_webserver:latest"
  }
}

resource "aws_ecs_task_definition" "ecs_task_web" {
  family = "ecs_task_web"
  container_definitions = "${data.template_file.ecs_task_container_definitions.rendered}"
  cpu = "256"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  memory = "512"
  requires_compatibilities = [
    "FARGATE"]
  network_mode = "awsvpc"
}

resource "aws_ecs_service" "ecs_service_web" {
  name = "ecs_service_web"
  cluster = "${aws_ecs_cluster.ecs_cluster_web.id}"
  task_definition = "${aws_ecs_task_definition.ecs_task_web.arn}"
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets = [
      "${aws_subnet.main_subnet_a.id}",
      "${aws_subnet.main_subnet_b.id}"]
    assign_public_ip = "true"
    security_groups = [
      "${aws_security_group.security_group_web.id}"]
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.target_group_web.arn}"
    container_name = "webserver"
    container_port = 80
  }

  depends_on = [
    aws_alb_target_group.target_group_web]
}

# \ ECS