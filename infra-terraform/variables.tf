#
#===============================================================================
# EU-WEST
#===============================================================================
#

variable "password_lookup" {
    default = "$(TF_VAR_ROOT_PASSWORD)"
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
  id = "g6-standard-2"
}

variable "svc_name" {}

variable "env_name" {}

variable "loc_name" {}

variable "instance_tags" {}

variable "counts" {}

variable "domain" {
  default = "fanmode.com"
}

#resource "linode_domain" "domain" {
#    domain = var.domain
#    soa_email = "support@${var.domain}"
#    type = "master"
#}

resource "linode_domain_record" "a-record" {
    domain_id = 835044
    record_type = "A"
    name = "prod-registry01-uk.fanmode.com"
    target = linode_instance.instance.0.ip_address
}

resource "linode_domain_record" "aaaa" {
    domain_id = 835044
    record_type = "AAAA"
    name = "prod-registry01-v6-uk.fanmode.com"
    target = element(split("/", linode_instance.instance.0.ipv6), 0)
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