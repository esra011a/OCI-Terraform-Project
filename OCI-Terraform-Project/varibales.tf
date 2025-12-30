variable "tenancy_ocid" {
   default="ocid1.tenancy.oc1.."//Enter your tenancy ocid here

}
//compartment
variable "Training-Project_name" {}
variable "Training-Project_description" {}
variable "create_internet_gateway" {}
variable "create_nat_gateway" {}
 variable "subnet_cidr_block" {}
 variable "cidr_block" {}

variable "public_sn_cidr" {
}
variable "public_sn_display_name" {
  
}
variable "label_prefix" {
  
}

variable "subnet_count" {
  
}
variable "route_table_name" {
  
}
variable "instance-count" {
  default = 1
}
variable "nat_gateway_display_name" {
   default = "nat gateway"
}
variable "internet_gateway_display_name" {
   default = "internet gateway"
}
variable "vcn_dns_label" {
  default = "vcndns"
}
variable "vcn_cidr" {
  
}
variable "vcn_display_name" {
  
}
variable "shape_load_balancer" {
  
}