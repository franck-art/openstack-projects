variable "security_groups" {
  description = ""
  type = map(object({
    direction      = string
    prefix         = string
    port_range_min = optional(number)
    port_range_max = optional(number)
    protocol       = string
  }))

  default = {
    "ssh" = {
      direction      = "ingress"
      prefix         = "0.0.0.0/0"
      port_range_min = 22
      port_range_max = 22
      protocol       = "tcp"
    },
    "http" = {
      direction      = "ingress"
      prefix         = "0.0.0.0/0"
      port_range_min = 80
      port_range_max = 80
      protocol       = "tcp"
    },
    "https" = {
      direction      = "ingress"
      prefix         = "0.0.0.0/0"
      port_range_min = 443
      port_range_max = 443
      protocol       = "tcp"
    },
    "icmp" = {
      direction = "ingress"
      prefix    = "0.0.0.0/0"
      protocol  = "icmp"
    }
  }
}
