locals {
  session_user          = "ubuntu"
  session_user_password = "ubuntu"
  subnet_id             = "subnet-0fd57f105c180dc38" # Development-VPC Public 1
}

variable "image_version" {
  type        = string
  default     = "x.x.x"
  description = "The version of the image to create."
}

variable "distro_short_name" {
  type        = string
  default     = "jammy"
  description = "The Ubuntu Linux distribution (short) code name."
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_development_vpc_id" {
  type        = string
  description = "The vpc id."
}

variable "user_password" {
  type        = string
  description = "the primary user password"
}

variable "user_salt" {
  type        = string
  description = "the primary user password salt"
}
