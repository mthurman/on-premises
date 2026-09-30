locals {
  # Keep the upstream rule matrix and split only its destinations. The legacy
  # allow-all egress binding contains separate IPv4 and IPv6 AWS rule IDs.
  # Keys use list positions, so an unknown peer SG ID cannot change the keys.
  tagged_rule_targets = flatten([
    for key, rule in local.keyed_resource_rules : concat(
      [for index, cidr in rule.cidr_blocks : {
        key                          = "${key}#ipv4#${index}"
        rule                         = rule
        cidr_ipv4                    = cidr
        cidr_ipv6                    = null
        prefix_list_id               = null
        referenced_security_group_id = null
      }],
      [for index, cidr in rule.ipv6_cidr_blocks : {
        key                          = "${key}#ipv6#${index}"
        rule                         = rule
        cidr_ipv4                    = null
        cidr_ipv6                    = cidr
        prefix_list_id               = null
        referenced_security_group_id = null
      }],
      [for index, prefix in rule.prefix_list_ids : {
        key                          = "${key}#prefix#${index}"
        rule                         = rule
        cidr_ipv4                    = null
        cidr_ipv6                    = null
        prefix_list_id               = prefix
        referenced_security_group_id = null
      }],
      length(rule.cidr_blocks) + length(rule.ipv6_cidr_blocks) + length(rule.prefix_list_ids) == 0 ? [{
        key                          = "${key}#group"
        rule                         = rule
        cidr_ipv4                    = null
        cidr_ipv6                    = null
        prefix_list_id               = null
        referenced_security_group_id = rule.self == true ? local.security_group_id : rule.source_security_group_id
      }] : [],
    )
  ])
  tagged_rules = { for target in local.tagged_rule_targets : target.key => target }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for key, target in local.tagged_rules : key => target if target.rule.type == "ingress" }

  security_group_id            = local.security_group_id
  ip_protocol                  = each.value.rule.protocol
  from_port                    = each.value.rule.protocol == "-1" ? null : each.value.rule.from_port
  to_port                      = each.value.rule.protocol == "-1" ? null : each.value.rule.to_port
  description                  = each.value.rule.description
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = module.this.tags

  depends_on = [aws_security_group.cbd, aws_security_group.default]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for key, target in local.tagged_rules : key => target if target.rule.type == "egress" }

  security_group_id            = local.security_group_id
  ip_protocol                  = each.value.rule.protocol
  from_port                    = each.value.rule.protocol == "-1" ? null : each.value.rule.from_port
  to_port                      = each.value.rule.protocol == "-1" ? null : each.value.rule.to_port
  description                  = each.value.rule.description
  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  tags                         = module.this.tags

  depends_on = [aws_security_group.cbd, aws_security_group.default]

  lifecycle {
    create_before_destroy = true
  }
}
