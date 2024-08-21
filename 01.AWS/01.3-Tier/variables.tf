variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/20"
}

variable "web_dev_pub1_cidr" {
  description = "Public Subnet 1 CIDR"
  default     = "10.0.10.0/24"
}

variable "web_dev_pub2_cidr" {
  description = "Public Subnet 2 CIDR"
  default     = "10.0.11.0/24"
}

variable "was_dev_pri1_cidr" {
  description = "Private Subnet 1 CIDR"
  default     = "10.0.20.0/24"
}

variable "was_dev_pri2_cidr" {
  description = "Private Subnet 2 CIDR"
  default     = "10.0.21.0/24"
}

variable "db_dev_pri1_cidr" {
  description = "Private Subnet 1 CIDR"
  default     = "10.0.30.0/24"
}

variable "db_dev_pri2_cidr" {
  description = "Private Subnet 2 CIDR"
  default     = "10.0.31.0/24"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c2acfcb2ac4d02a0"  # Example, change to your AMI ID
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  default     = "terraform-key"
}
