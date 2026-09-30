# Forget only the old Terraform bindings, preserving the AWS rules. The calling
# root must import every existing sgr-* ID into its new named rule address in
# the same plan. This also splits the old multi-CIDR EFS binding into two rules.
removed {
  from = aws_security_group_rule.computed_ingress_with_source_security_group_id
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_security_group_rule.ingress_with_cidr_blocks
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_security_group_rule.egress_with_cidr_blocks
  lifecycle {
    destroy = false
  }
}
