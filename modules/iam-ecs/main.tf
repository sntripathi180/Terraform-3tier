locals {
    name_prefix = "${var.project_name}-${var.environment}"

}

resource "aws_iam_role" "ecs_instance" {
    name = "${local.name_prefix}-ecs-instance-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {Service = "ec2.amazonaws.com"}
            Action = "sts:AssumeRole"
        }]
    })

    tags = var.tags
}


resource "aws_iam_role_policy_attachment" "ecs_instance_core" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${local.name_prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}


resource "aws_iam_role" "task_execution" {
    name = "${local.name_prefix}-ecs-task-execution-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Service = "ecs-tasks.amazonaws.com"}
            Action = "sts:AssumeRole"
        }]
    })
    tags = var.tags
}


resource "aws_iam_role_policy_attachment" "task_execution" {
    role = aws_iam_role.task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "frontend_task" {
  name = "${local.name_prefix}-frontend-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}


resource "aws_iam_role" "backend_task" {
  name = "${local.name_prefix}-backend-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}


resource "aws_iam_role_policy" "backend_task_secrets" {
  count = length(var.backend_secret_arns) > 0 ? 1 : 0
  name  = "${local.name_prefix}-backend-secrets-read"
  role  = aws_iam_role.backend_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = var.backend_secret_arns
    }]
  })
}
