# Política del Load Balancer
resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AmazonEKSLoadBalancerControllerPolicyTF"
  path        = "/"
  description = "Policy for load balancer controller on EKS"
  policy      = file("${path.module}/iam_policy.json")
}

# Rol del Load Balancer
resource "aws_iam_role" "load_balancer_controller" {
  name = "AmazonEKSLoadBalancerControllerRoleTF"

  # Terraform's "jsonencode" function converts a 
  # Terraform expression result to valid Json syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Sid    = ""

      Principal = {
        Federated = "${module.eks.oidc_provider_arn}"
      }
      "Condition" = {
        "StringEquals" = {
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
   tags = {
    Environment = "staging"
    Terraform   = "true"
  }
}

# Se adjunta la politica a el rol
resource "aws_iam_policy_attachment" "load_balancer_controller" {
  name       = "AmazonEKSLoadBalancerControllerPolicyTF"
  roles      = [aws_iam_role.load_balancer_controller.name]
  policy_arn = aws_iam_policy.load_balancer_controller.arn

}

# Política del Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "AmazonEKSClusterAutoscalerPolicyTF"
  description = "Policy for cluster autoscaler on EKS"
  path        = "/"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

# Rol del Cluster Autoscaler
resource "aws_iam_role" "cluster_autoscaler" {
  name = "AmazonEKSClusterAutoscalerRoleTF"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""

        Principal = {
          Federated = "${module.eks.oidc_provider_arn}"
        }

        Condition = {
          StringEquals = {
            # IMPORTANTE: el sub debe coincidir con el SA del CA
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "staging"
    Terraform   = "true"
  }
}

# Adjuntar la política al rol
resource "aws_iam_policy_attachment" "cluster_autoscaler" {
  name       = "AmazonEKSClusterAutoscalerPolicyTF"
  roles      = [aws_iam_role.cluster_autoscaler.name]
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}
