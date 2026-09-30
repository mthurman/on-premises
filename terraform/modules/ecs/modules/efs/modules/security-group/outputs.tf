output "id" {
  description = "The created or target Security Group ID"
  value       = local.security_group_id
}

output "arn" {
  description = "The created Security Group ARN (null if using existing security group)"
  value       = try(local.created_security_group.arn, null)
}

output "name" {
  description = "The created Security Group Name (null if using existing security group)"
  value       = try(local.created_security_group.name, null)
}

output "rules_terraform_ids" {
  description = "IDs of the individual managed rules, primarily provided to enable `depends_on`"
  value       = concat(values(aws_vpc_security_group_ingress_rule.this)[*].id, values(aws_vpc_security_group_egress_rule.this)[*].id)
}
