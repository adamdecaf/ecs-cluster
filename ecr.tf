resource "aws_ecr_repository" "default" {
  name = "redis"
}

resource "aws_ecr_repository_policy" "default" {
  repository = "${aws_ecr_repository.default.name}"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "default policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

variable "aws_cli_executable" {
  description = "The name of the aws cli executable on your $PATH"
  default = "aws"
}

# 'docker login' on the local machine
resource "null_resource" "ecr_docker_login" {
  provisioner "local-exec" {
    command = "`${var.aws_cli_executable} ecr get-login --registry-ids ${aws_ecr_repository.default.registry_id}`"
  }
}
