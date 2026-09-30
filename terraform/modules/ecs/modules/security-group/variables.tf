variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ingress" {
  description = "Inbound rules keyed by stable purpose; supply one CIDR or source SG per rule. Omit port for all protocols."
  type = map(object({
    ip_protocol       = string
    description       = string
    port              = optional(number)
    cidr_ipv4         = optional(string)
    security_group_id = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.ingress) :
      (rule.cidr_ipv4 == null) != (rule.security_group_id == null)
    ])
    error_message = "Each ingress rule must specify exactly one CIDR or source security group."
  }
}

variable "egress" {
  description = "Outbound rules keyed by stable purpose; supply one CIDR or destination SG per rule. Omit port for all protocols."
  type = map(object({
    ip_protocol       = string
    description       = string
    port              = optional(number)
    cidr_ipv4         = optional(string)
    security_group_id = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.egress) :
      (rule.cidr_ipv4 == null) != (rule.security_group_id == null)
    ])
    error_message = "Each egress rule must specify exactly one CIDR or destination security group."
  }
}
