module "eks" {
	source  = "terraform-aws-modules/eks/aws"
	version = "~> 20.0"
	
	cluster_name = "caleidos-eks"
	cluster_version = "1.34" 
	
	vpc_id = module.vpc.vpc_id
	subnet_ids = module.vpc.private_subnets
	
	cluster_endpoint_private_access = true
	cluster_endpoint_public_access = true #false para prod
	
	enable_cluster_creator_admin_permissions = true

	cluster_addons = {
		coredns = {
			resolve_conflict = "OVERWRITE"
		}
		
		vpc-cni = {
			resolve_conflict = "OVERWRITE"
		}
		
		kube-proxy = {
			resolve_conflict = "OVERWRITE"
		}
		
	}
	
	eks_managed_node_groups = {
		node-group  ={
			desired_capacity = 1
			max_capacity = 5
			min_capacity = 1
			instance_types = ["t3.small"]
			disk_size = 20
			subnets = module.vpc.private_subnets
			tags = {
				Environment = "Test"	
			}
		}
		
	}
	
	tags = {
		Terraform = true
		Environment = "Test"
	}
}

data "aws_eks_cluster" "cluster" {
	name = module.eks.cluster_name
	depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "cluster" {
	name  = module.eks.cluster_name
	depends_on = [ module.eks ]
}

provider "kubernetes" {
	host = data.aws_eks_cluster.cluster.endpoint
	cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
	token = data.aws_eks_cluster_auth.cluster.token
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}

output "oidc_provider_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
}


output "oidc_provider" {
  value = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}
