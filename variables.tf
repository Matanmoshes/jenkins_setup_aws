variable "ami" {
    description = "AMI for the EC2 instances"
    type        = string
    default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
    description = "Instance type for the EC2 instances"
    type        = string
    default     = "t3.medium"
}

variable "public_subnet_cidr" {
    description = "CIDR block for public subnet"
    type        = string
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR block for private subnet"
    type        = string
    default     = "10.0.2.0/24"
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "key_name" {
    description = "Key pair name for EC2 instances"
    type        = string
    default = "22-09-24-key"
}
