# Forceing user to give value
variable "cidr_block" {
    
}

# optional, but default is true.
variable "enable_dns_hostnames" {
    default = true
}
# optional, but default is true.
variable "enable_dns_support" {
    default = true
}

# optional, but good to give values.
variable "common_tags" {
    default = {} # This means tags is optional.
    type = map
}

variable "vpc_tags" {
    default = {} # This means tags is optional.
    type = map
}
# Forceing user to give project name.
variable "project_name" {

}

variable "igw_tags" {
    default = {}  # This means tags is optional.
  
}

## Public Subnet Variables
variable "public_subnet_cidr" {
  type        = list
  validation {
    condition     = length(var.public_subnet_cidr) == 2
    error_message = "Please provide 2 public subnets cidr"
  }
}

## Private Subnet Variables
variable "private_subnet_cidr" {
  type        = list
  validation {
    condition     = length(var.private_subnet_cidr) == 2
    error_message = "Please provide 2 private subnets cidr"
  }
}

## Database Subnet Variables
variable "database_subnet_cidr" {
  type        = list
  validation {
    condition     = length(var.database_subnet_cidr) == 2
    error_message = "Please provide 2 database subnets cidr"
  }
}

# Nat -Gateway
variable "nat_gateway_tags" {
  default = {}
}

# Public_route_table_tags
variable "public_route_table_tags" {
  default = {}
}

# Private_route_table_tags
variable "private_route_table_tags" {
  default = {}
}

# Database_route_table_tags
variable "database_route_table_tags" {
  default = {}
}

# Database_subnet_group_tags
variable "db_subnet_group_tags" {
  default = {}
  
}

