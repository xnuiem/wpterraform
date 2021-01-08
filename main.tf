provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

resource "aws_vpc" "web_vpc" {
  cidr_block           = var.CIDR

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(
  {
    "Name" = "web.${var.ENV}.vpc",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_subnet" "web_subnet1" {
  vpc_id = aws_vpc.web_vpc.id
  cidr_block = var.CIDR_1
  availability_zone = var.AZ_1

  tags = merge(
  {
    "Name" = "web.${var.ENV}.subnet.1",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_subnet" "web_subnet2" {
  vpc_id = aws_vpc.web_vpc.id
  cidr_block = var.CIDR_2
  availability_zone = var.AZ_2

  tags = merge(
  {
    "Name" = "web.${var.ENV}.subnet.2",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_security_group" "web-ssh-sg" {
  name    = "web-ssh-${var.ENV}-sg"
  vpc_id  = aws_vpc.web_vpc.id
  tags = merge(
  {
    "Name" = "web-ssh-${var.ENV}-sg",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "SSH"
    cidr_blocks = [var.DEFAULT_ADMIN_IP]
  }
}

resource "aws_internet_gateway" "web_internet_gw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = merge(
  {
    "Name" = "web-${var.ENV}-gw",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_lb" "web_alb" {
  name               = "web-${var.ENV}-alb-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-ssh-sg.id, aws_security_group.web-http-sg.id]
  subnets            = [aws_subnet.web_subnet1.id, aws_subnet.web_subnet2.id]

  access_logs {
    bucket  = aws_s3_bucket.web_logs.id
    prefix  = "web-${var.ENV}"
    enabled = true
  }

  tags = merge(
  {
    "Name" = "web-${var.ENV}-alb",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_security_group" "web-db-sg" {
  name    = "web-db-${var.ENV}-sg"
  vpc_id  = aws_vpc.web_vpc.id
  tags = merge(
  {
    "Name" = "web-db-${var.ENV}-sg",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    description = "MySQL"
    cidr_blocks = [var.DEFAULT_ADMIN_IP]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    description = "MySQL"
    security_groups = [aws_security_group.web-http-sg.id]

  }
}

resource "aws_security_group" "web-http-sg" {
  name    = "web-http-${var.ENV}-sg"
  vpc_id  = aws_vpc.web_vpc.id
  tags = merge(
  {
    "Name" = "web-http-${var.ENV}-sg",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "HTTPS"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "web_logs" {
  bucket = "${var.TLD}-${var.ENV}-logs"
  acl    = "private"
  force_destroy = true

  tags = merge(
  {
    "Name" = "${var.TLD}-${var.ENV}-logs",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.web_logs.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:PutObjectRetention",
                "s3:PutObjectTagging",
                "s3:PutObjectLegalHold",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::${var.TLD}-${var.ENV}-logs/*"
        }
     ]
}
POLICY
}

resource "aws_lb_listener" "web_listener_https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_listener" "web_listener_http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.TLD
  validation_method = "DNS"

  tags = merge(
  {
    "Name" = "web-${var.ENV}-crt",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "web_alias" {
  zone_id = var.DNS_ZONE_ID
  name    = var.TLD
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_certificate" "web_alb_cert" {
  listener_arn    = aws_lb_listener.web_listener_https.arn
  certificate_arn = aws_acm_certificate.cert.arn
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-${var.ENV}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id
}

resource "aws_route53_record" "web_dns" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.DNS_ZONE_ID
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.web_dns : record.fqdn]
}

resource "aws_main_route_table_association" "web" {
  vpc_id         = aws_vpc.web_vpc.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.web_vpc.id

  tags = merge(
  {
    "Name" = "web-${var.ENV}-route-table",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

resource "aws_route_table_association" "web1" {
  subnet_id = aws_subnet.web_subnet1.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "web2" {
  subnet_id = aws_subnet.web_subnet2.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route" "web" {
  route_table_id = aws_route_table.web.id
  gateway_id = aws_internet_gateway.web_internet_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "web" {
  vpc   = true
  tags = merge(
  {
    "Name" = "web-${var.ENV}-eip",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}


resource "aws_db_instance" "web_db" {
  allocated_storage    = var.DB_SIZE
  storage_type         = var.DB_STORAGE_TYPE
  engine               = "mysql"
  engine_version       = var.ENGINE_VERSION
  instance_class       = var.INSTANCE_CLASS
  name                 = var.DB_NAME
  username             = var.DB_USERNAME
  password             = var.DB_PASSWORD
  parameter_group_name = var.PARAMETER_GROUP
  vpc_security_group_ids = [aws_security_group.web-db-sg.id]
  skip_final_snapshot  = true

  identifier        = "web-${var.ENV}-db"
  count             = 1

  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = merge(
  {
    "Name" = "web-${var.ENV}-db",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

}

resource "aws_db_subnet_group" "default" {
  name       = "web.${var.ENV}.db.subnet"
  subnet_ids = [aws_subnet.web_subnet1.id, aws_subnet.web_subnet2.id]

  tags = merge(
  {
    "Name" = "web-${var.ENV}-db",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )
}

data "template_file" "build" {
  template = file("build.yaml")

  vars = {
    RDS_HOST                    = aws_db_instance.web_db[0].address
    RDS_DB_NAME                 = var.DB_NAME
    RDS_DB_USERNAME             = var.DB_USERNAME
    RDS_DB_PASSWORD             = var.DB_PASSWORD
    RDS_DB_PORT                 = var.DB_PORT
    TLD                         = var.TLD
    ADMIN_EMAIL                 = var.ADMIN_EMAIL
    ADMIN_USERNAME              = var.ADMIN_USERNAME
    ADMIN_PASSWORD              = var.ADMIN_PASSWORD
    WP_NAME                     = "web-${var.ENV}"
    DB_PREFIX                   = var.DB_PREFIX
  }

}

resource "aws_instance" "web_portal" {
  count                       = 1

  ami                         = var.AMI
  instance_type               = var.INSTANCE_TYPE
  subnet_id                   = aws_subnet.web_subnet1.id
  key_name                    = "web-${var.ENV}-ssh"
  vpc_security_group_ids      = [aws_security_group.web-http-sg.id, aws_security_group.web-ssh-sg.id]
  associate_public_ip_address = var.PUBLIC_IP
  user_data                   = data.template_file.build.rendered


  dynamic "root_block_device" {
    for_each = var.ROOT_BLOCK_DEVICE
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  tags = merge(
  {
    "Name" = "web.${var.ENV}.vpc",
    "Environment" = var.ENV,
    "Owner" = var.OWNER_TAG
  },
  var.tags,
  )

  provisioner "file" {
    source      = "wordpress.conf"
    destination = "~/wordpress.conf"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.PEM_FILE_NAME)
    }
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_portal[0].id
  port             = 80
}















