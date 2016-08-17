[
  {
    "name": "redis",
    "image": "${redis_docker_image}",
    "cpu": 10,
    "memory": 100,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 6379,
        "hostPort": 6379
      }
    ]
  }
]
