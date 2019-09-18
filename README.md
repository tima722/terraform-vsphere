# terraform-vsphere
Creating virtual machines with terraform and change scsi_bus_sharing with ansible.

Installing virtual machines in Vsphere with shared disk env between two or three virtual machine with terraform.

For now terraform not support change scsi_bus_sharing in different scsi controllers.So with ansible as automation tool we can change scsi_bus sharing to physical in second scsi controller
