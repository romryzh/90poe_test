provider "aws" {
    region = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

terraform {
  backend "s3" {
    bucket = "my-test-jenkins-mysql-backup"
    key    = "web.tfstate"
    region = "eu-west-3"
  }
}
