terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0.0"
    }
  }
}

# Retain the address, generated name and lifecycle from security-group/aws v4.
# Omitting inline rules preserves the existing standalone rule ownership.
resource "aws_security_group" "this_name_prefix" {
  count = 1

  name_prefix            = "${var.name}-"
  description            = "Security Group managed by Terraform"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = false
  tags                   = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    create = "10m"
    delete = "15m"
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress

  security_group_id            = aws_security_group.this_name_prefix[0].id
  referenced_security_group_id = each.value.security_group_id
  cidr_ipv4                    = each.value.cidr_ipv4
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.port
  to_port                      = each.value.port
  description                  = each.value.description
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress

  security_group_id            = aws_security_group.this_name_prefix[0].id
  referenced_security_group_id = each.value.security_group_id
  cidr_ipv4                    = each.value.cidr_ipv4
  ip_protocol                  = each.value.ip_protocol
  from_port                    = each.value.port
  to_port                      = each.value.port
  description                  = each.value.description
  tags                         = var.tags
}

output "security_group_id" {
  description = "The existing security group ID"
  value       = aws_security_group.this_name_prefix[0].id
}
