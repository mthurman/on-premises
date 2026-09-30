# Keep the AWS rules while their individual IDs are imported by the caller.
removed {
  from = aws_security_group_rule.redis_ingress_self
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_security_group_rule.redis_ingress_cidr_blocks
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_security_group_rule.redis_egress
  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_security_group_rule.other_sg_ingress
  lifecycle {
    destroy = false
  }
}
