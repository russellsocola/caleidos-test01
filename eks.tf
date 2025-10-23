module "eks" {
	source  = "terraform-aws-modules/eks/aws"
	version = "~> 20.0"
	
	cluster_name = "caleidos-eks"
	cluster_version = "1.34" 
	
	vpc_id = module.vpc.vpc_id
	subnet_ids = module.vpc.private_subnets
	
	cluster_endpoint_private_access = true #false para prod
	cluster_endpoint_public_access = true
	
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
		
		csi = { # si da problemas ponerlo "aws-ebs-csi-driver"
			resolve_conflict = "OVERWRITE"
		}
	}
	
	manage_aws_auth_configmap = true
	
	eks_maneged_node_groups = {
		node-group  ={
			desired_capacity = 1
			max_capacity = 2
			min_capacity = 1
			instance_types = ["t3.medium"]
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
}

data "aws_eks_cluster_auth" "cluster" {
	name  = module.eks.cluster_name
}

provider "kubernetes" {
	host = data.aws_eks_cluster.cluster.endpoint
	cluster_ca_certificate = base64code(data.aws_eks_cluster.cluster.certificate_authority[0].data)
	token = data.aws_eks_cluster_auth.cluster.token
}