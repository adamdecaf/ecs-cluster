variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default = "production"
}

variable "ecs_min_workers" {
  default = 1
}

variable "ecs_max_workers" {
  default = 1
}

variable "ecs_desired_workers" {
  default = 1
}

resource "aws_key_pair" "ecs" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.key_file)}"
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = <<EOT
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOT
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name     = "ecs_service_role_policy"
  policy   = "${template_file.ecs_service_role_policy.rendered}"
  role     = "${aws_iam_role.ecs_role.id}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name     = "ecs_instance_role_policy"
  policy   = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecs:StartTask",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    }
  ]
}
EOT
  role     = "${aws_iam_role.ecs_role.id}"
}

# todo: doesn't work for some reason

# resource "aws_security_group" "ecs" {
#   name = "ecs-sg"
#   description = "Container Instance Allowed Ports"
#   vpc_id      = "${var.vpc_id}"

#   ingress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags {
#     Name = "ecs-sg"
#   }
# }

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  path = "/"
  roles = ["${aws_iam_role.ecs_role.name}"]
}

resource "template_file" "ecs_service_role_policy" {
  template = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOT
}

resource "aws_launch_configuration" "ecs" {
  name                 = "ecs"

  image_id             = "${lookup(var.amis, var.region)}"
  instance_type        = "${var.instance_type}"
  key_name             = "${aws_key_pair.ecs.key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"

  # security_groups      = ["${aws_security_group.ecs.id}"]
  security_groups      = ["sg-360f3252"] # todo

  associate_public_ip_address = true

  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.production.name} > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "ecs-asg"
  availability_zones   = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.subnet_ids)}"]

  launch_configuration = "${aws_launch_configuration.ecs.name}"

  min_size             = "${var.ecs_min_workers}"
  max_size             = "${var.ecs_max_workers}"
  desired_capacity     = "${var.ecs_desired_workers}"

  tag {
    key = "Name"
    value =  "ecs worker"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "production" {
  name = "${var.ecs_cluster_name}"
}

output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.production.id}"
}
