variable "vpc_cidr" {
  type    = string

}

variable "public_cidrs" {
  type    = string

}

variable "private_cidrs" {
  type    = string
  
}

variable "instance_type" {
  type = string
}

variable "amazon_linux_ami" {
  type = string
}

variable "main_vol_size" {
  type    = number
  default = 8
}

variable "jenkins_ip" {
  type = string
}


variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string

}

