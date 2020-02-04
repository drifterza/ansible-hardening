#
#===============================================================================
# Resources
#===============================================================================
#

resource "linode_instance" "registry" {
    count = lookup(var.counts, "instances")
    label = "${var.svc_name}-${var.loc_name}-${var.env_name}-${format("%02d", count.index + 1)}.${var.domain}"
    region = var.loc_name
    type = data.linode_instance_type.default.id
    private_ip = true
    tags = [ var.instance_tags ]
    config {
      label  = "My Debian 10 Disk Profile"
      kernel = "linode/grub2"
      root_device = "/dev/sda"  
      devices {
        sda {
          disk_label = "Debian 10 Disk"
        }
        sdb {
          disk_label = "512 MB Swap Image"
        }
      }
    }

    disk {
      label           = "Debian 10 Disk"
      size            = "80000" 
      authorized_keys = [ "${linode_sshkey.andrew.ssh_key}", "${linode_sshkey.donovan.ssh_key}", "${linode_sshkey.kaveer.ssh_key}" ]
      root_pass       = var.password_lookup
      image           = data.linode_image.debian.id
    }
    disk {
      label = "512 MB Swap Image"
      size = "512"
    }
}
