variable "ssh_keypair_name" {
  description = "Key pair mame to log into EC2 instances"
  default     = "test-app-key"
}

variable "vpc_id" {
  description = "VPC ID"
  default     = "vpc-9dced7f5"
}

variable "ssh_key_public" {
        default     = "keys/test-app-key.pub"
        description = "Path to the SSH public key."
}

variable "ssh_key_private" {
        default     = "keys/test-app-key"
        description = "Path to the SSH public key."
}

variable "server_instance_type" {
        default         = "t2.micro"
        description     = "Instance type"
}

variable "access_key" {
        default         = "AKIAWEMSKNOGQIDC2BCP"
        description     = "IAM Access Key"
}

variable "secret_key" {
        default         = "L9I3TUWx+VDSdvFLGOAOIgz/N0HT8BLoQdp2JSf6"
        description     = "IAM Secret Key"
}

variable "ubuntu_18_04_LTS" {
        default         = "ami-05c1fa8df71875112"
        description     = "Ubuntu Server 18.04 LTS"
}

variable "region" {
        default         = "us-east-2"
        description     = "AWS Region"
}

variable "dns_name" {
        default         = "fromterraform"
        description     = "DNS name"
}
