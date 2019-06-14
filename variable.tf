variable "access_key" {
default = "AKIATEAHT76NUXXXX"
}
variable "secret_key" {
default = "mLtNFHvhQ8H5Clqd78wwh4jc7YgAPGXXXXX"
}

variable "aws_default_user" {
  default = "ec2-user"
}

variable "region" {
  default = "ap-south-1"
}

variable "instancetype" {
  default = "t2.micro"
}

variable "private_key" {
default = "gogokey"
}

variable "public_key" {
default = "gogokey.pub"
}

variable "availability_zone1" {
  default = "ap-south-1a"
}

variable "availability_zone2" {
  default = "ap-south-1b"
}

variable "environment_tag" {
  description = "Environment Tag"
  default = "DEV"
}
