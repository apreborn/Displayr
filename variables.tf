variable "region" {
default = "ap-southeast-2"
}
variable "instance_type" {
default = "t2.micro"
}
variable "creds_path" {
default = "~/.aws/"
}
variable "creds_file" {
default = "credentials"
}
variable "instance_key" {
default = "terraform-key"
}
variable "vpc_cidr" {
default = "178.0.0.0/16"
}
variable "public_subnet_cidr" {
default = "178.0.10.0/24"
}
