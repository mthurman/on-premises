# The old keyed egress binding contains both IPv4 and IPv6. The caller imports
# both native IDs plus the two NFS ingress IDs before assuming rule ownership.
removed {
  from = aws_security_group_rule.keyed
  lifecycle {
    destroy = false
  }
}
