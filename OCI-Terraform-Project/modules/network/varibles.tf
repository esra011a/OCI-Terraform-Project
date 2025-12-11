variable "compartment_id" {
  
}
variable "tenancy_ocid" {
  default   = "ocid1.tenancy.oc1..aaa"//Enter your tenancy ocid here

}
variable "subnet_count" {
 default="1"
}
variable "vcn_dns_label" {
  
}
variable "label_prefix" {
  
}
variable "vcn_display_name" {
  default = "Training-VCN"
}

variable "public_sn_display_name" {
  
}
variable "public_sn_cidr" {
}
variable "route_table_name" {
  
}
variable "internet_gateway_display_name" {
  default = "internet gateway"
}
variable "subnets" {
}
variable "security_lists" {
  
}
variable "nat_gateway_display_name" {
  default = "nat gateway"
}

variable "cidr_block" {
  
}
variable "subnet_display_name" {
 default = "subnet name "
}

variable "subnet_cidr_block" {

}
variable "create_internet_gateway" {
  type=bool
 
}
variable "create_nat_gateway" {
  type=bool
  
}
 