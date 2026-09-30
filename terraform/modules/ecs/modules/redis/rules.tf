resource "aws_vpc_security_group_ingress_rule" "self" {
  count = var.ingress_self ? 1 : 0

  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.redis.id
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  description                  = "Redis access from members of the Redis security group"
  tags                         = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ipv4" {
  for_each = { for index, cidr in var.ingress_cidr_blocks : tostring(index) => cidr }

  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
  description       = "Redis access from an allowed ${var.name_prefix} subnet"
  tags              = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "clients" {
  for_each = { for index, sg in var.allowed_security_groups : tostring(index) => sg }

  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  description                  = "Redis access from an allowed ${var.name_prefix} client"
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ipv4" {
  for_each = { for index, cidr in var.egress_cidr_blocks : tostring(index) => cidr }

  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
  description       = "Unrestricted outbound access for ${var.name_prefix} Redis"
  tags              = var.tags
}
