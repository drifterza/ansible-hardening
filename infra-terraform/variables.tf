#
#===============================================================================
# EU-WEST (UK)
#===============================================================================
#

variable "root_password" {}

variable "public_ssh_key" {
  description = "SSH Public Key Fingerprint"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_ssh_key" {
  description = "SSH Public Key Fingerprint"
  default     = "~/.ssh/id_rsa"
}


#
#===============================================================================
# Generic
#===============================================================================
#

data "linode_image" "debian" {
  id = "linode/debian10"
}

data "linode_instance_type" "default" {
  id = "g6-standard-4"
}

variable "token" {}

variable "svc_name" {}

variable "env_name" {}

variable "loc_name" {}

variable "instance_tags" {}

variable "counts" {}

variable "domain" {
  default = "fanmode.com"
}

#
#===============================================================================
# Linode DNS
#===============================================================================
#

resource "linode_domain_record" "a-record" {
    domain_id = 835044
    record_type = "A"
    name = "prod-registry01-uk.fanmode.com"
    target = linode_instance.registry.0.ip_address
}

resource "linode_domain_record" "aaaa" {
    domain_id = 835044
    record_type = "AAAA"
    name = "prod-registry01-v6-uk.fanmode.com"
    target = element(split("/", linode_instance.registry.0.ipv6), 0)
}

resource "linode_domain_record" "CNAME-registry" {
  domain_id   = 835044
  record_type = "CNAME"
  name        = "registry"
  target      = "prod-registry01-uk.fanmode.com"
}

resource "linode_domain_record" "CNAME-registry6" {
  domain_id   = 835044
  record_type = "CNAME"
  name        = "registry6"
  target      = "prod-registry01-v6-uk.fanmode.com"
}