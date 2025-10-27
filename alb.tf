resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.load_balancer_controller.arn
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [kubernetes_service_account.alb_controller]
}

resource "kubernetes_ingress_v1" "php_apache_ingress" {
  metadata {
    name      = "php-apache-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.php_apache.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.alb_controller,
    kubernetes_service.php_apache
  ]
}