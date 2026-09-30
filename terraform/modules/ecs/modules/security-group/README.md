# ECS security groups with tagged rules

Internal replacement for the security-group/aws v4 calls in the ECS module.
It keeps `aws_security_group.this_name_prefix[0]`, generated names, descriptions,
tags, timeouts and lifecycle settings. Only the rule bindings change. Provider
default tags and the caller's tags apply to every new rule.

Existing deployments must import each AWS `sgr-*` ID into its named ingress or
egress resource in the same plan as this module upgrade. The `removed` blocks
forget the old rule bindings with `destroy = false`; they do not revoke access.
An old rule with multiple CIDRs needs one new import per AWS rule ID. Reject a
plan that creates or destroys rules or replaces any security group during this
handoff. Fresh deployments create the named rules normally.

The private-subnet EFS grants intentionally preserve their legacy all-protocol
access. Restricting that access is a separate change.

After adoption, keep the new bindings when reverting tags or descriptions.
Reverting the module source without a state handoff can revoke imported rules.
