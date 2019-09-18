#===============================================================================
# vSphere Provider
#===============================================================================

provider "vsphere" {
  version              = "1.11.0"
  vsphere_server       = "${var.vsphere_vcenter}"
  user                 = "${var.vsphere_user}"
  password             = "${var.vsphere_password}"
  allow_unverified_ssl = "${var.vsphere_unverified_ssl}"
}

#===============================================================================
# vSphere Data
#===============================================================================

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_drs_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


data "vsphere_virtual_machine" "template" {
  name          = "${var.vm_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
#===============================================================================
# vSphere Resources
#===============================================================================
resource "vsphere_folder" "folder" {
    path          = "${var.vm_folder}"
    type          = "vm"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
  }

  # Create the Kubernetes master VMs #
  resource "vsphere_virtual_machine" "master" {
    count          = "${length(var.vm_master_ips)}"
    name           = "${var.vm_name_prefix}master0${count.index +1}"
    resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id   = "${data.vsphere_datastore.datastore.id}"
    folder         = "${vsphere_folder.folder.path}"


  num_cpus         = "${var.vm_master_cpu}"
  memory           = "${var.vm_master_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"

  network_interface {
    network_id     = "${data.vsphere_network.network.id}"
    adapter_type   = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.vm_name_prefix}master0${count.index +1}"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "${var.vm_name_prefix}master0${count.index +1}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.vm_master_ips, count.index)}"
        ipv4_netmask = "${var.vm_netmask}"
      }

      ipv4_gateway    = "${var.vm_gateway}"
      dns_server_list = ["${var.vm_dns}"]
    }
  }
}
resource "vsphere_virtual_disk" "shareddisk_1" {
  vmdk_path         = "${var.vm_name_prefix}worker01.shareddisk1.vmdk"
  size              = "${var.shared_disk_size}"
  datacenter        = "${var.vsphere_datacenter}"
  datastore         = "${var.vm_datastore}"
  type              = "eagerZeroedThick"
  }
# Create the Kubernetes worker VMs #
resource "vsphere_virtual_machine" "worker" {
  count            = "${length(var.vm_worker_ips)}"
  name             = "${var.vm_name_prefix}worker0${count.index +1}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${vsphere_folder.folder.path}"
  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"
  scsi_controller_count  = "2"

#########################################################
  num_cpus         = "${var.vm_worker_cpu}"
  memory           = "${var.vm_worker_ram}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"
  enable_disk_uuid = "true"
  shutdown_wait_timeout = "1"
  force_power_off = true


  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "${var.vm_name_prefix}worker0${count.index +1}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
    unit_number      = 0
    disk_sharing     = "sharingNone"
    disk_mode        = "persistent"
  }

  disk { ## This will be the disk that we created prior
	attach           = true
	path             = "${vsphere_virtual_disk.shareddisk_1.vmdk_path}"
	label            = "${var.vm_name_prefix}worker0${count.index +1}.shareddisk1"
	unit_number      = 15
	datastore_id     = "${data.vsphere_datastore.datastore.id}"
  thin_provisioned = false
	disk_sharing     = "sharingMultiWriter"
  disk_mode        = "independent_persistent"
	}


  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = "${var.vm_linked_clone}"

    customize {
      timeout = "20"

      linux_options {
        host_name = "${var.vm_name_prefix}worker0${count.index +1}"
        domain    = "${var.vm_domain}"
      }

      network_interface {
        ipv4_address = "${lookup(var.vm_worker_ips, count.index)}"
        ipv4_netmask = "${var.vm_netmask}"
      }

      ipv4_gateway    = "${var.vm_gateway}"
      dns_server_list = ["${var.vm_dns}"]
    }
  }
provisioner "local-exec" {
    command = "ansible-playbook -i inventory site.yaml" 
  }
}
