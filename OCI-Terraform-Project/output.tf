output "vcn_id" {
  value=module.vcn.vcn_id
}

output "publicSubnet_id" {
  value = module.vcn.publicSubnet_id
}
output "subnet_A_id" {
  value = module.vcn.subnet_A_id
}
output "subnet_B_id" {
  value = module.vcn.subnet_B_id
}

output "WindowsVM-id" {
  value = module.compute["Windows-VM"].id
}
output "LinuxVM-id" {
  value = module.compute["Linux-VM"].id
}


output "compartment_id" {
  value = oci_identity_compartment.Training-Project.compartment_id
}
output "windosvm-private-ip" {
  value = local.instances["Windows-VM"].private_ip
}
output "linuxvm-private-ip" {
  value = local.instances["Linux-VM"].private_ip
}
