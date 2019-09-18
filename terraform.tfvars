#===============================================================================
# VMware vSphere configuration
#===============================================================================

# vCenter IP or FQDN #
vsphere_vcenter = "1.1.1.1"

# vSphere username used to deploy the infrastructure #
vsphere_user = "administrator@vsphere.local"
# Vsphere user password
vsphere_password = "password"
vm_privilege_password = "root"
vm_password = "password"
# Skip the verification of the vCenter SSL certificate (true/false) #
vsphere_unverified_ssl = "true"

# vSphere datacenter name where the infrastructure will be deployed #
vsphere_datacenter = "DATACENTER"

# vSphere cluster name where the infrastructure will be deployed #
vsphere_drs_cluster = "CLUSTER"

# Enable anti-affinity between the Kubernetes master virtual machines. This feature require a vSphere enterprise plus license #
vsphere_enable_anti_affinity = "false"
#===============================================================================
# Global virtual machines parameters
#===============================================================================

# Username used to SSH to the virtual machines #
vm_user = "ansible"

# The linux distribution used by the virtual machines (ubuntu/debian/centos/rhel) #
vm_distro = "centos"

# The prefix to add to the names of the virtual machines #
vm_name_prefix = "test"

# The name of the vSphere virtual machine and template folder that will be created to store the virtual machines #
vm_folder = "kubernetes"

# The datastore name used to store the files of the virtual machines #
vm_datastore = "datastore01"

# The vSphere network name used by the virtual machines #
vm_network = "VLANx"

# The netmask used to configure the network cards of the virtual machines (example: 24)#
vm_netmask = "22"

# The network gateway used by the virtual machines #
vm_gateway = "1.1.1.2"

# The DNS server used by the virtual machines #
vm_dns = "8.8.8.8"

# The domain name used by the virtual machines #
vm_domain = "test.local"

# The vSphere template the virtual machine are based on #
vm_template = "kubernetes-template"

# Use linked clone (true/false)
vm_linked_clone = "false"

#===============================================================================
# Master node virtual machines parameters
#===============================================================================

# The number of vCPU allocated to the master virtual machines #
vm_master_cpu = "2"

# The amount of RAM allocated to the master virtual machines #
vm_master_ram = "2048"

# The IP addresses of the master virtual machines. You need to define 3 IPs for the masters #
vm_master_ips = {
  "0" = "1.1.1.3"
  "1" = "1.1.1.4"
  "2" = "1.1.1.5"
}

#===============================================================================
# Worker node virtual machines parameters
#===============================================================================

# The number of vCPU allocated to the worker virtual machines #
vm_worker_cpu = "2"

# The amount of RAM allocated to the worker virtual machines #
vm_worker_ram = "2048"

# The IP addresses of the master virtual machines. You need to define 1 IP or more for the workers #
vm_worker_ips = {
  "0" = "1.1.1.6"
  "1" = "1.1.1.7"
  "2" = "1.1.1.8"
}

shared_disk_size = "5"
