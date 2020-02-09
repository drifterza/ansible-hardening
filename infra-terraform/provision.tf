#
#===============================================================================
# Linode Instance
#===============================================================================
#

resource "linode_instance" "registry" {
    boot_config_label  = "My Debian 10 Disk Profile"
    count              = lookup(var.counts, "instances")
    label = "${var.env_name}-${var.svc_name}${format("%02d", count.index + 1)}-uk"
    private_ip         = true
    region             = var.loc_name
    tags               = [ var.instance_tags ]
    type               = data.linode_instance_type.default.id
    watchdog_enabled   = true
    alerts {
        cpu            = 90
        io             = 10000
        network_in     = 10
        network_out    = 10
        transfer_quota = 80
    }
    
    connection {
      host        = self.ip_address
      type        = "ssh"
      user        = "root"
      agent       = "false"
      private_key = chomp(file(var.private_ssh_key))
    }

    disk {
        authorized_keys = [chomp(file(var.public_ssh_key))]
        authorized_users = []
        filesystem       = "ext4"
        label            = "Debian 10 Disk"
        read_only        = false
        size             = 51200
        root_pass        = var.root_password
        image            = data.linode_image.debian.id


    }
    
    disk {
        authorized_keys  = []
        authorized_users = []
        filesystem       = "swap"
        label            = "512 MB Swap Image"
        read_only        = false
        size             = 512
    }

    config {
      kernel       = "linode/grub2"
      label        = "My Debian 10 Disk Profile"
      memory_limit = 0
      root_device  = "/dev/sda"
      run_level    = "default"
      virt_mode    = "paravirt"
      devices {
        sda {
          disk_label = "Debian 10 Disk"
          volume_id  = 0
        }
        sdb {
          disk_label = "512 MB Swap Image"
          volume_id  = 0
        }
    }

    helpers {
      devtmpfs_automount = true
      distro             = true
      modules_dep        = true
      network            = true
      updatedb_disabled  = true
     }
    }
  timeouts {}
}