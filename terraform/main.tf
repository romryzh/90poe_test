
data "aws_vpc" "main_vpc" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "main_vpc_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_key_pair" "test_app_key" {
        key_name   = "${var.ssh_keypair_name}"
        public_key = "${file(var.ssh_key_public)}"
}

resource "aws_security_group" "app_sg" {
        name            = "ssh_http"
        description     = "For web and ssh access"

        ingress {  
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }
        ingress {  
                from_port       = 22
                to_port         = 22
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        egress  {  
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags = {
                Name = "SSH-HTTP"
        }

}

resource "aws_security_group" "lb_sg" {
        name            = "http"
        description     = "For web access"

        ingress {  
                from_port       = 80
                to_port         = 80
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

                ingress {  
                from_port       = 443
                to_port         = 443
                protocol        = "tcp"
                cidr_blocks     = ["0.0.0.0/0"]

        }

        egress  {  
                from_port       = 0
                to_port         = 0
                protocol        = -1
                cidr_blocks     = ["0.0.0.0/0"]
        }

        tags = {
                Name = "HTTP"
        }

}


data "aws_iam_policy_document" "rds_access" {
    statement {
        actions = [
           "rds-db:connect"]
        resources = [
            "arn:aws:rds-db:us-east-1:421750533005:dbuser:db-7N2ACAPEWZC25GPY7ODK4K4CZA/ec2"]
    }
}

resource "aws_iam_policy" "rds_access" {
    name = "rds_acces"
    policy = "${data.aws_iam_policy_document.rds_access.json}"
}

resource "aws_iam_role" "rds_access" {
    name = "rds_access"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rds_access" {
    role = "${aws_iam_role.rds_access.name}"
    policy_arn = "${aws_iam_policy.rds_access.arn}" 
}

resource "aws_iam_instance_profile" "web_rds" {
    name = "web_rds"
    role = "${aws_iam_role.rds_access.name}"
}

resource "aws_instance" "web" {
        ami = "${var.ubuntu_18_04_LTS}"
        instance_type = "${var.server_instance_type}"
        key_name = "test-app-key"
        vpc_security_group_ids = ["${aws_security_group.app_sg.id}"]
        iam_instance_profile = "${aws_iam_instance_profile.web_rds.name}"
        tags = {
            Name = "App"
        }

        provisioner "remote-exec" {
            inline = ["echo ec2 instance is avaible via SSH! && sleep 10"]
            connection {
                type        = "ssh"
                user        = "ubuntu"
                private_key = "${file(var.ssh_key_private)}"
                host = "${self.public_ip}"
            }
        }

        provisioner "local-exec" {
            command = "ansible-playbook ansible/test_deploy.yml -i '${self.public_ip},' --private-key=keys/test-app-key --user ubuntu"
        }

}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.test1995.com"
  validation_method = "DNS"
}



resource "aws_lb_target_group" "web" {
    name = "web"
    port = 80
    protocol = "HTTP"
    vpc_id = "${data.aws_vpc.main_vpc.id}"
}

resource "aws_lb_target_group_attachment" "main_web" {
  target_group_arn = "${aws_lb_target_group.web.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}

resource "aws_lb" "main" {
  name               = "main"
  internal           = false
  load_balancer_type = "application"
  subnets = "${data.aws_subnet_ids.main_vpc_subnets.ids}"
  security_groups = ["${aws_security_group.lb_sg.id}"]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"

    redirect {
        port = "443"
        protocol = "HTTPS"
        status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.cert.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web.arn}"
  }
}

data "aws_route53_zone" "selected" {
    name = "test1995.com."
}

resource "aws_route53_record" "alias_record" {
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name = "${var.dns_name}.${data.aws_route53_zone.selected.name}"
    type = "A"

    alias {
        name = "${aws_lb.main.dns_name}"
        zone_id = "${aws_lb.main.zone_id}"
        evaluate_target_health = true
    }
    
}

output "site_url" {
    value = "https://${aws_route53_record.alias_record.name}"
}
