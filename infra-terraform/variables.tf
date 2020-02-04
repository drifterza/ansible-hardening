#
#===============================================================================
# EU-WEST
#===============================================================================
#

variable "token" {
    default = "$(TF_VARS_LINODE_API_KEY)"
}

variable "password_lookup" {
    default = "$(TF_VARS_ROOT_PASSWORD)"
}

resource "linode_sshkey" "andrew" {
  label = "andrew"
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXj8GAPEp8Iod7C3UFBGiczT9YmEiYFDVXtPfQzUT3s90Db0/srALzqlnkMR65cC/PCqbwj54d5Ly05chEThj3njYiDzen5XmZHZ93YPHfN9XEeTlkCkErAGnc0uImctMN5Zih2RX1BahoZdIyBBjnxDAr36HEJl1vwnF6yvQrzd4IF73XwcWKeSTofgYWdwEuDWdeGWY3w+97LjwMndV0RmaqWAWSELoEvnSST/twHiO5FF8LkEdeyib07DeMva7tNqmfsYi4pJpjexVghb14tsP5dYGuX2Q2umvd9K7T7sIGwdo2xb3SNXQXixiVmWEbTRK5uuc6Otn7QsvwGLEK6bSmACTbBoKy1g7TIEfY+rzsc0sEjhdoNvf8rYLqHSuANJiRhTgX8wePwPiLCMWDFcNQ3vrUCd3fp+Wb3xfXknQo2quiV3w50Ht1/jyrhvl/Scmbyvu5FIG4ixC7KVYgD57PMDWwmakEPdcFe5U92zYDIYFHbawZjODkZp//dVPHG3DlJDQkr1um877VjUlKCvbSDz/M6SKAmhmw3Q5nIXZeG0c2CP5WO13fgxMTi6kXtZuo0Io8dzN7rXDzCG8RuDxmtHjE8B1EQ/8c8eXeBLg20CKuRcvo2noEV4ejKB2udb9xuI3Akd/3uGcnrvVaJV9xQI9Va5Jsi7GPsNGi9w== Andrew@AndrewKlopper"
}

resource "linode_sshkey" "donovan" {
  label = "donovan"
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDVYZCD5TQaG40GcsS6ysKhqlS5aX3YrO29c/t3MdDYA82gqex6CQvxkvhKsY8JzMB3EFfUBhcp85U68phDCigizxv1DD0UVrLEyAORqI/uktQMj14peeNmHaHdCy2BgHCr3ywh9IewzYO9YAwZ3yrL0Ubi14CG73h4SBlhnSx4M3L/HHvUcvXno7aFjdYl5Ma4ZW+LOScZ1ZAFC8Aa3vsIbkmbPHzfHeoVuVv2+eRGfPUThbuXu1U8eKiGwxuAH1Ybfx2u8pUSFdhLtOQxz4IeSX+tA06lhxn1bBL/OjMyEXvIJecJOqRIBJEKCRdmZsJeiRFnid06GMLteXcyZu1 donovan@donovan-HP-ProBook-650-G1"
}

resource "linode_sshkey" "kaveer" {
  label = "kaveer"
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaeVVaRg2xO2kggz/V1q85LZriPnqwpgAiQ0fKcObF3EoRAun/RWGsVOpM4vsYJxswph72gvbYBm3t00myLY5kbSnoLIYQoQVT2QN+FphZjprHIJ/OdGLcXFiIqIOhCnDHv7R0vG7YokzLD645OTNwcm8o3cAto4gIhzdD/PXQBcZu7p6J0V6aT8W2mWOwG6TmO9vLwy+cwxYqJWdVqo7FFoqBmormk0eP1WW0vcCxkoDhJTkjeQ3qzVae04ByNvEALAG2lVk+ohu6SS6hBRlJHbAiwDKxiVJQYOLBk5o7YRuJSaoHuZct9OlALiJRuUI9lHkw+YyH76r0pHaiLu0h kaveerh@kaveers-MacBook-Pro.local"
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

variable "domain" {}

resource "linode_domain" "domain" {
    domain = var.domain
    soa_email = "support@${var.domain}"
    type = "master"
}

resource "linode_domain_record" "a-record" {
    domain_id = linode_domain.domain.id
    record_type = "A"
    name = "registry-eu-west-prod-01.fanmode.com"
    target = linode_instance.registry.0.ip_address
}

resource "linode_domain_record" "aaaa" {
    domain_id = linode_domain.domain.id
    record_type = "AAAA"
    name = "registry6-eu-west-prod-01.fanmode.com"
    target = element(split("/", linode_instance.registry.0.ipv6), 0)
}

resource "linode_domain_record" "CNAME-registry" {
  domain_id   = linode_domain.domain.id
  record_type = "CNAME"
  name        = "registry"
  target      = "registry-eu-west-prod-01.fanmode.com"
}

resource "linode_domain_record" "CNAME-registry6" {
  domain_id   = linode_domain.domain.id
  record_type = "CNAME"
  name        = "registry6"
  target      = "registry6-eu-west-prod-01.fanmode.com"
}