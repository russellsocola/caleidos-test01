resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AmazonEKSLoadBalancerControllerPolicyTF"
  path        = "/"
  description = "Policy for load balancer controller on EKS"
  policy      = file("${path.module}/iam_policy.json")
}

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

resource "aws_iam_policy_attachment" "load_balancer_controller" {
  name       = "AmazonEKSLoadBalancerControllerPolicyTF"
  roles      = [aws_iam_role.load_balancer_controller.name]
  policy_arn = aws_iam_policy.load_balancer_controller.arn

}
