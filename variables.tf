variable "private_subnets" {
  default     = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
  }
}

variable "public_subnets"{
    default = {
        "public_subnet_1" = 1
        "public_subnet_2" = 2
    }
}
variable "vpc_cidr" {
    type = string
    default = "10.98.0.0/16"
}