variable "region" {}

variable "support-vpc" {}

variable "key-name" {}

variable "data-center" {}

variable "consul-servers" {
  description = "Number of Consul Servers"
  default     = 3
  type        = number
}

variable "consul-clients" {
  description = "Number of Consul Clients"
  default     = 0
  type        = number
}

variable "required-tags" {
  type = map(string)
  default = {
    ExpiryDate = "2022-12-16"
    Terraform  = "true"
    consul_join = "true"
  }
}

variable "consul-sg-ingress-rules" {

  type = list(object({

    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string

  }))

  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "ssh"
    },
    {
      from_port   = 8300
      to_port     = 8300
      protocol    = "tcp"
      cidr_block  = "172.31.0.0/16"
      description = "server-rpc"
    },
    {
      from_port   = 8301
      to_port     = 8301
      protocol    = "tcp"
      cidr_block  = "172.31.0.0/16"
      description = "lan-serf"
    },
    {
      from_port   = 8302
      to_port     = 8302
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "wan-serf"
    },
    {
      from_port   = 8301
      to_port     = 8301
      protocol    = "udp"
      cidr_block  = "172.31.0.0/16"
      description = "lan-serf"
    },
    {
      from_port   = 8302
      to_port     = 8302
      protocol    = "udp"
      cidr_block  = "0.0.0.0/0"
      description = "wan-serf"
    },
    {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      cidr_block  = "172.31.0.0/16"
      description = "http-api"
    },
    {
      from_port   = 8500
      to_port     = 8500
      protocol    = "tcp"
      cidr_block  = "/32"
      description = "http-api-your-network"
    },
    {
      from_port   = 8501
      to_port     = 8501
      protocol    = "tcp"
      cidr_block  = "172.31.0.0/16"
      description = "https-api"
    },
    {
      from_port   = 8600
      to_port     = 8600
      protocol    = "tcp"
      cidr_block  = "172.31.0.0/16"
      description = "dns-tcp"
    },
    {
      from_port   = 8600
      to_port     = 8600
      protocol    = "udp"
      cidr_block  = "172.31.0.0/16"
      description = "dns-udp"
    }
  ]

}