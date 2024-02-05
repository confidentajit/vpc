
variable "cidr" {
  default= "172.16.0.0/16"
}

variable "availability_zone" {
  type = list(string)
  default= ["us-east-1b","us-east-1a"]
}

variable "instance_type" {
  default= "t2.micro"
}
variable "subnet_cidr" {
  type = list
  default = ["172.16.1.0/24" , "172.16.2.0/24"]
}
variable "azs" {
	type = list
	default = ["us-east-1a", "us-east-1b"]
}
variable "subnet-name" {
  type = list
  default=["public-subnet-1","public-subnet-2"]
}
variable "name" {
  default= "Dev-env"
}
variable "instancename" {
  type = list(string)
  default = ["instance-1","instance-2"]
}
