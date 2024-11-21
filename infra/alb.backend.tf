# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${terraform.workspace}-backend-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.core.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-backend-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "backend" {
  name               = "${terraform.workspace}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.core_public[*].id

  enable_deletion_protection = true
  enable_http2               = true


  tags = {
    Name = "${terraform.workspace}-backend-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "backend" {
  name        = "${terraform.workspace}-backend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.core.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${terraform.workspace}-backend-tg"
  }
}


# HTTP Listener (redirects to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}



# resource "aws_iam_role" "runner_role" {
#   name = "main-backend-runner-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::072468034689:oidc-provider/token.actions.githubusercontent.com"
#         }
#         Condition = {
#           StringEquals = {
#             "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
#           }
#           StringLike = {
#             "token.actions.githubusercontent.com:sub" = "repo:melontron/cloud_engineering_deep_dive:*"
#           }
#         }
#       },
#     ]
#   })
# }

# Attach the policy to the role 
# resource "aws_iam_role_policy_attachment" "runner_policy_attachment" {
#   role       = aws_iam_role.runner_role.name
#   policy_arn = aws_iam_policy.runner_policy.arn
# }


# IAM Policy for the runner
# resource "aws_iam_policy" "runner_policy" {
#   name        = "runner-policy"
#   path        = "/"
#   description = "Policy for runner EC2 instance"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "*"
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }