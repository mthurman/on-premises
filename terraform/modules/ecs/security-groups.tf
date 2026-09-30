module "database_sg" {
  source = "./modules/security-group"
  count  = var.database_endpoint == "" ? 1 : 0

  name   = "${var.prefix}-database-sg"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  tags   = var.tags

  ingress = merge(
    var.restrict_ingress_to_security_groups ? {} : {
      for index, cidr in local.private_subnet_cidrs : "private_${index}" => {
        cidr_ipv4   = cidr
        ip_protocol = "tcp"
        port        = var.database_port
        description = "Database access from within VPC"
      }
    },
    {
      tasks = {
        security_group_id = module.fargate_sg.security_group_id
        ip_protocol       = "tcp"
        port              = var.database_port
        description       = "Database access from Polytomic tasks"
      }
    },
  )
}

module "fargate_sg" {
  source = "./modules/security-group"

  name   = "${var.prefix}-fargate_task"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  tags   = var.tags

  ingress = merge(
    var.restrict_ingress_to_security_groups ? {} : {
      public = {
        cidr_ipv4   = "0.0.0.0/0"
        ip_protocol = "tcp"
        port        = var.polytomic_port
        description = "Public HTTP access to Polytomic tasks"
      }
    },
    {
      for index, sg in local.lb_sgs : "load_balancer_${index}" => {
        security_group_id = sg
        ip_protocol       = "tcp"
        port              = var.polytomic_port
        description       = "HTTP access from Polytomic load balancer"
      }
    },
  )

  egress = {
    ipv4 = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
      description = "Outbound IPv4 access for Polytomic tasks"
    }
  }
}

module "efs_sg" {
  source = "./modules/security-group"

  name   = "${var.prefix}-efs"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  tags   = var.tags

  # The legacy rule specified port 2049 with protocol -1, which allows every
  # protocol and port. Preserve that access during the tagging migration.
  ingress = {
    for index, cidr in local.private_subnet_cidrs : "private_${index}" => {
      cidr_ipv4   = cidr
      ip_protocol = "-1"
      description = "Legacy all-protocol access from a Polytomic private subnet"
    }
  }
}

module "lb_sg" {
  source = "./modules/security-group"
  count  = length(var.load_balancer_security_groups) == 0 ? 1 : 0

  name   = "${var.prefix}-lb"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  tags   = var.tags

  ingress = {
    http = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      port        = 80
      description = "Public HTTP access to the Polytomic load balancer"
    }
    https = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      port        = 443
      description = "Public HTTPS access to the Polytomic load balancer"
    }
  }

  egress = {
    ipv4 = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
      description = "Outbound IPv4 access for the Polytomic load balancer"
    }
  }
}
