resource "oci_identity_compartment" "Training-Project" {
  compartment_id = var.tenancy_ocid
  name=var.Training-Project_name
  description =var.Training-Project_description
  
 freeform_tags = {
    "Environment" = "Dev"
    "Owner"       = "Esra"
    "Project"     = "OCI Training"
  }

}

locals {
  subnets={
           
subnet_A = {
  cidr                = "10.250.0.0/24" //A :0
  sn_display_name     = "subnet_A"
  security-list-name  = "subnet_A_SL"
  dns_label           = "subneta"
  subnet_display_name ="subnet_A"
}
subnet_B = {
  cidr                = "10.250.1.0/24" //B:1
  sn_display_name     = "subnet_B"
  security-list-name  = "subnet_B_SL"
  dns_label           = "subnetb"
  subnet_display_name="subnet_B"
  
}                                        // public : 2
  }
  
 security_lists={
   subnet_A_SL={
    display_name="subnet_A_SL"
    ingress = [
      
        {
        stateless    = false 
        source       = "10.250.2.0/24"//LB subnet
        source_type  = "CIDR_BLOCK"
        protocol     = "6"
   
         min     = 80
         max      = 443
       

      },
       {
           protocol    = "6" // null        
           source      = "172.22.48.0/23" // null
           source_type = "CIDR_BLOCK" // null
           stateless   = false // null      
            # (1 unchanged attribute hidden) 

           min = 3389
         max = 3389
        },
      
      
{
  stateless   = false 
  protocol = "6"
  source   = "10.250.2.0/24"//pub subnet
        source_type  = "CIDR_BLOCK"
 
    min = 3389
    max = 3389//RDP (Remote Desktop Protocol) for Windows.
  }

    ]

   
   egress_security_rules= {
    protocol = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
   }
    }
     subnet_B_SL={
    display_name="subnet_B_SL"
    ingress = [
     {
        stateless    = false
        source       = "10.250.2.0/24"//pub subnet
        source_type  = "CIDR_BLOCK"
        protocol     = "6"
      
         min       = 80
        max          = 443
      
      }
      ,
      {
        stateless    = false
        source       = "10.250.2.0/24"
        source_type  = "CIDR_BLOCK"
        protocol     = "6"
      
         min       = 22
        max          = 22//min = 22, max = 22 → allows SSH for Linux.
      },
      {
           protocol    = "6" // null        
           source      = "172.22.48.0/23" // null
           source_type = "CIDR_BLOCK" // null
           stateless   = false // null      
           

           min = 3389
         max = 3389
        }
    ]
   egress_security_rules= {
    protocol = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
   }
    }
   }
   
  
}

module "vcn" {
  source = "./modules/network"
    label_prefix=var.label_prefix
  cidr_block = var.cidr_block
  vcn_display_name = var.vcn_display_name
  vcn_dns_label = var.vcn_dns_label
  subnet_cidr_block = var.cidr_block
  compartment_id = oci_identity_compartment.Training-Project.id
  route_table_name = var.route_table_name
  create_nat_gateway= var.create_nat_gateway
  create_internet_gateway = var.create_internet_gateway
  internet_gateway_display_name=var.internet_gateway_display_name
    nat_gateway_display_name=var.nat_gateway_display_name
   
 subnet_count=var.subnet_count
 security_lists=local.security_lists
  subnets = local.subnets
public_sn_cidr  = var.public_sn_cidr

  public_sn_display_name  = var.public_sn_display_name
}

locals {
  count ="1"
  instances ={
 Windows-VM={
  subnet_id=module.vcn.subnet_A_id
  display_name="Windows-VM"
   ocpus="1"
  memory_in_gbs="4"
  assign_public_ip=false
  vm_vinic_name="Windows-VM-vinic"
  instance_shape="VM.Standard.E5.Flex"
  private_ip="10.250.0.3"
  APP_OWNER="Esra"
  Environment="Dev"
  enable_encryption=true
  ssh_key=""
  source_type="image"
source_id=""//Enter your image ocid here
 }    
Linux-VM={
  count ="1"
  subnet_id=module.vcn.subnet_B_id
 display_name="Linux-VM"
  ocpus=1
  memory_in_gbs=1
  assign_public_ip=false
  vm_vinic_name="Linux-VM-vinic"
  instance_shape="VM.Standard.A1.Flex"
  private_ip="10.250.1.3"
  APP_OWNER="Esra"
  Environment="Dev"
  enable_encryption=true
source_type="image"
ssh_key=""//Enter your ssh key here
source_id=""//Enter your image ocid here
 
}

  }
}
module "compute" {
  source = "./modules/compute"
  compartment_id = oci_identity_compartment.Training-Project.id
  for_each = local.instances
  subnet_id=each.value.subnet_id
  instance_display_name = each.value.display_name
 ocpus = each.value.ocpus
  memory_in_gbs = each.value.memory_in_gbs
  assign_public_ip=each.value.assign_public_ip
  vm_vinic_name = each.value.vm_vinic_name
  instance_shape = each.value.instance_shape
  private_ip = each.value.private_ip
  APP_OWNER = each.value.APP_OWNER
  Environment = each.value.Environment
  enable_encryption = each.value.enable_encryption
  ssh_key = each.value.ssh_key
  source_id = each.value.source_id
  source_type = each.value.source_type
  
}
resource "oci_bastion_bastion" "bastion" {
  bastion_type    = "STANDARD"
  compartment_id  = oci_identity_compartment.Training-Project.id
  target_subnet_id = module.vcn.publicSubnet_id
  name            = "training-bastion"
  client_cidr_block_allow_list = ["0.0.0.0/0"]
}

output "bastion_id" {
  value = oci_bastion_bastion.bastion.id
}




