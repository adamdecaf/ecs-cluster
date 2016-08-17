variable "redis_docker_image" {
  # todo: depend on concat+output from other resource
  default = "741412628301.dkr.ecr.us-east-1.amazonaws.com/redis:3.2"
}

# move to an example

resource "template_file" "redis_task" {
  template = "${file("${path.module}/task-definitions/redis.json.tpl")}"
  vars {
    redis_docker_image = "${var.redis_docker_image}"
  }
}

resource "aws_ecs_service" "redis" {
  name            = "redis"
  cluster         = "${aws_ecs_cluster.production.id}"
  task_definition = "${aws_ecs_task_definition.redis.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]
}

resource "aws_ecs_task_definition" "redis" {
  family                = "redis"
  container_definitions = "${template_file.redis_task.rendered}"
}
