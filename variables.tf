variable "AWS_ACCESS_KEY" {
  type = string
}

variable "AWS_SECRET_KEY" {
  type = string
}

variable "AWS_REGION" {
  type = string
  description = "AWS Region"
  default = "us-west-1"
}

variable "ENV" {
  type = string
  default = "dev"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {
    AVS                   = "Internal"
    Terraform             = "1"
  }
}

variable "OWNER_TAG" {
  description = "The Owner tag for resources"
  type = string
}

variable "DEFAULT_ADMIN_IP" {
  description = "The default IP address for port 22 access"
  type = string
}

variable "CIDR" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.30.0/24"
}

variable "CIDR_1" {
  description = "CIDR for subnet 1"
  type = string
  default = "10.0.30.0/25"
}

variable "CIDR_2" {
  description = "CIDR for subnet 2"
  type = string
  default = "10.0.30.128/25"
}

variable "AZ_1" {
  description = "AZ 1"
  type = string
  default = "us-west-1b"
}

variable "AZ_2" {
  description = "AZ 2"
  type = string
  default = "us-west-1c"
}

variable "DNS_ZONE_ID" {
  description = "Zone ID for Domain"
  type = string
}

variable "TLD" {
  description = "Top Level Domain Name"
  type = string
}

variable "INSTANCE_CLASS" {
  description = "Instance Class for the RDS Instance"
  type = string
  default = "db.t2.micro"
}

variable "ENGINE_VERSION" {
  description = "DB Engine Version"
  type = string
  default = "5.7"
}

variable "DB_NAME" {
  description = "Database Name"
  type = string
  default = "web"
}

variable "DB_USERNAME" {
  description = "Database User Name"
  type = string
}

variable "DB_PASSWORD" {
  description = "Database Password"
  type = string
}

variable "DB_SIZE" {
  description = "Database Storage Size"
  type = string
  default = 20
}

variable "DB_STORAGE_TYPE" {
  description = "Database Storage Type"
  type = string
  default = "gp2"
}

variable "PARAMETER_GROUP" {
  description = "DB Parameter Group Name"
  type = string
  default = "default.mysql5.7"
}

variable "AMI" {
  description = "ID of AMI to use"
  type = string
}

variable "PUBLIC_IP" {
  description = "Use Public IP"
  type = bool
  default = true
}

variable "INSTANCE_TYPE" {
  description = "What type of instance.  Defaults to t2.medium"
  type = string
  default = "t2.medium"
}

variable "ROOT_BLOCK_DEVICE" {
  description = "Define the root device"
  type = list(map(string))
  default = [{
    "delete_on_termination" = "true"
    "encrypted"             = "true"
    "iops"                  = "1000"
    "kms_key_id "           = ""
    "volume_size"           = "10"
    "volume_type"           = "gp2"

  }]
}


variable "DB_PORT" {
  description = "RDS Port MySQL"
  type        = number
  default     = 3306
}

variable "ADMIN_EMAIL" {
  description = "Email for WP Admin"
  type = string
}

variable "ADMIN_USERNAME" {
  description = "Admin Username for WP"
  type = string
}

variable "ADMIN_PASSWORD" {
  description = "Password for WP Admin"
  type = string
}

variable "DB_PREFIX" {
  description = "The table prefix for the database"
  type = string
  default = "wp_"
}

variable "PEM_FILE_NAME" {
  type = string
  description = "Name of the PEM file to login to the EC2 Instance.  Should already be created and placed in the top directory of the terraform script."
}