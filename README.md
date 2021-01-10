# WP Terraform
Terraform build script for WordPress in AWS.

# Summary
This script will create a fully functioning WordPress website in AWS.  

# Requirements
## AWS Services Used
* EC2
* RDS (MySQL)
* Route 53
* S3

# Quick Start


## Variables
The script now needs several variables to run.

### DB_USERNAME
The username to access your database.<br />
<b>Default:</b> wp_db_user

### DB_PASSWORD
The password to access your database. *** Please change before using in Production<br />
<b>Default:</b> S0m3P@ssW0rd

### DB_NAME
The name of your database. <br />
<b>Default:</b> web

### DEFAULT_ADMIN_IP
Your IP Address with prefix length. This is the public IP address you are accessing AWS from. 
It is used to keep SSH access locked down to a single IP Address. 
This needs to be the IP address you are running this script from. <br />
Use <a href="https://whatismyipaddress.com/">What Is My IP Address</a> to find your public IP.<br />
<b>Default:</b> NONE<br />
<b>Example:</b> 127.0.0.1/32

### AWS_ACCESS_KEY
Your AWS Access Key<br />
<a href="https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html">How to Obtain a Key</a><br />
<b>Default:</b> NONE

### AWS_SECRET_KEY
Your AWS Secret Key<br />
<b>Default:</b> NONE

### PEM_FILE_NAME
The PEM File used to access your server.  <br />
<a href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html">How to Create PEM File</a><br />
<b>Default:</b> NONE<br />
<b>Example:</b> web-ssh-key-file.pem

### DNS_ZONE_ID
Hosted Zone ID for your Route 53 zone to add this website to.<br />
<a href="https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html">Create Hosted Zone in AWS Route 53</a><br />
<b>Default:</b> NONE

### OWNER_TAG
Your name.  Used in the tags. <br />
<b>Default:</b> WP Terraform

### AMI
ID of the AMI to use.  The default is a Ubuntu distro.  This script is ONLY tested on Ubuntu.
It may work on other Linux flavors, but it was not tested. <br />
<b>Default:</b> ami-00831fc7c1e3ddc60

### ENV
Environment. (e.g. Prod, Dev, Test).  This is used mainly for tagging and naming<br />
<b>Default:</b> dev

### TLD
Your top level domain name<br />
<b>Default:</b> NONE<br />
<b>Example:</b> something.com

### ADMIN_USERNAME
WordPress Admin Username<br />
<b>Default:</b> NONE

### ADMIN_PASSWORD
WordPress Admin Password<br />
<b>Default:</b> NONE

### ADMIN_EMAIL
WordPress Admin Email Address<br />
<b>Default:</b> NONE

## Run
It is easiest to use the environment variables to pass the values to the script.  Each variable, when created as an environment variable, needs to have its name start with "TF_VAR_" so that Terraform can access it correctly.  
For example, the varible "DB_USERNAME" as an environment variable is set as "TF_VAR_DB_USERNAME".

Example export script:<br /><br />
export TF_VAR_DB_USERNAME="wp_db_user"; 
export TF_VAR_DB_PASSWORD="S0m3P@ssW0rd"; 
export TF_VAR_OWNER_TAG="WP Terraform"; 
export TF_VAR_DEFAULT_ADMIN_IP="&lt;IPADDRESS&gt;/32"; 
export TF_VAR_AWS_ACCESS_KEY=&lt;ACCESS KEY&gt;; 
export TF_VAR_AWS_SECRET_KEY=&lt;SECRET KEY&gt;; 
export TF_VAR_DB_NAME="web"; 
export TF_VAR_AMI="ami-00831fc7c1e3ddc60"; 
export TF_VAR_ENV="dev"; 
export TF_VAR_TLD="&lt;YOUR DOMAIN&gt;"; 
export TF_VAR_ADMIN_USERNAME="admin";
export TF_VAR_ADMIN_PASSWORD="@dm1nP@ssw0rd"; 
export TF_VAR_ADMIN_EMAIL="someone@gmail.com"; 
export TF_VAR_PEM_FILE_NAME="&lt;YOUR PEM FILE NAME&gt;"; 
export TF_VAR_DNS_ZONE_ID="&lt;ZONE ID&gt;";


The normal terraform commands work from here on out.  To build your resources:
* terraform init
* terraform apply --auto-approve

To destroy your resources:
* terraform destroy --auto-approve


# FAQ
None Yet

# Misc

<b>Author:</b> Xnuiem </br>
<b>Website:</b> https://thescrum.ninja

