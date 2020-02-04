#
#===============================================================================
# Outputs
#===============================================================================
#

output "linode_provision_domain_id" {
  value = "${linode_domain.domain.domain}"
}

output "linode_provision_ip_address" {
  value = "${linode_instance.registry.*.ip_address}"
}
