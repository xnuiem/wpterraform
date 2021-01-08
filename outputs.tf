output "web_vpc_id" {
  value = aws_vpc.web_vpc.id
  description = "ID of VPC just created."
}

output "web_subnet_1_id" {
  value = aws_subnet.web_subnet1.id
  description = "ID of 1st Subnet"
}

output "web_subnet_2_id" {
  value = aws_subnet.web_subnet2.id
  description = "ID of 2nd Subnet"
}

output "web_ssh_sg_id" {
  value = aws_security_group.web-ssh-sg.id
  description = "ID of SSH Security Group"
}

output "web_db_id" {
  value = aws_db_instance.web_db[0].id
  description = "ID of Web DB RDS Instance"
}

output "web_db_host" {
  value = aws_db_instance.web_db[0].address
  description = "Hostname of DB Instance"
}

output "web_target_group" {
  value = aws_lb_target_group.web_tg.arn
  description = "target group for the web ALB"
}

output "web_http_sg_id" {
  value = aws_security_group.web-http-sg.id
  description = "ID of HTTP Security Group"
}