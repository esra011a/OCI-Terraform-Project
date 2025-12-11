output "publicSubnet_id" {
  value = oci_core_subnet.vcn_public_subnet.id
}
output "subnet_A_id" {
  value = oci_core_subnet.Private_subnets["subnet_A"].id
}
output "subnet_B_id" {
  value = oci_core_subnet.Private_subnets["subnet_B"].id
}
output "vcn_id" {
  value = oci_core_vcn.vcn.id
}