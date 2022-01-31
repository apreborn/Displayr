The Goal of this Document is to set up a hello world web server in AWS, and write a script for the server health check.

## Source Code File Details
- https://github.com/apreborn/Displayr
- - The configured credentials stored in the file `~/.aws.credentials`
- We need to provide the reference for the above path in `shared_credentials_file` value using the `creds` variable
```
# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_file = var.creds
  profile = "default"
}
```
- `main.tf` should have the resource definition required for creating a `AWS EC2` instance
- We need to have below resources for creating an EC2 instance
  1. VPC
  2. Internet Gateway
  3. Subnet
  4. Route table
  5. Security Group
  6. EC2 instance definition

```
# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
```
## Cloud Init and User Data
- Objective of the EC2 instance is to have the Apache Web Server installed on it, when the instance is created
- So we are providing a shell script in `user_data` section to install the apache server
- The script added in `user_data` section will be invoked via `Cloud Init` functionality when the AWS server gets created


```resource "aws_instance" "web" {
  ami           = "ami-01dc883c13e87eeda" 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo yum update
  sudo yum install httpd -y
  sudo systemctl start httpd 
  sudo systemctl enable httpd
  echo '<!doctype html><html><body style="background-color:#6c98f5;"><h1 style="background-color:#1c283b; color:Tomato;">Hello Displayr!!</h1></body></html>' | sudo tee /var/www/html/index.html
  echo "*** Completed Installing apache2"
  EOF
  
  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  } 
}
```
- `variables.tf` file should have the customised variables, a user wanted to provide before running the infra creation
```
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
```
sg.tf` file for adding resource for AWS VPC security group
- sg.tf
```
resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allow ssh http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
```
- We can define `output.tf` file to see expected output values like `ipaddress` of instances and `hostname` etc.

- output.tf
```
output "web_instance_ip" {
    value = aws_instance.web.public_ip
}
```
- Since we have the custom variables defined in our terraform file, we have to provide the values for those custom variables
- So we have to create a `tfvars` files and provide the custom variable values
- User has to provide the EC2 instance `pem file` key name in `instance_key` value
- aws.tfvars
```
region =  "ap-southeast-2"
instance_type = "t2.micro"
instance_key = "terraform-key"
vpc_cidr = "178.0.0.0/16"
public_subnet_cidr = "178.0.10.0/24"
creds_path = "~/.aws/"
creds_file = "credentials"
```
## healthCheck Script
```
#!/bin/bash
DATE=$(date)
/usr/bin/curl -s --head  --request GET https://www.displayr.com | if ! grep "HTTP/2 200"; then
sudo service httpd restart
echo "$DATE - NOT OKAY, apache restarted" >> /var/log/httpd/custom-restarts.log
else
echo "$DATE - Apache running fine"
fi
```
- Steps to run healthcheck - ``` sudo sh healthcheck.sh```
- <img width="379" alt="healthcheck_script" src="https://user-images.githubusercontent.com/13806249/151778147-ff694082-7eef-4692-bf03-959fd686a81d.png">
## Steps to run Terraform
```
terraform init
terraform plan -var-file=aws.tfvars
terraform apply -var-file=aws.tfvars -auto-approve
```
- Once the `terrform apply` completed successfully it will show the `public ipaddress` of the apache server as `output`

```
aws_instance.web: Creation complete after 54s [id=i-0f0f8d436d50b2829]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

web_instance_ip = 54.253.184.15
``` 
## Access the Webserver
- We can access the webserver using the public IP
- Screenshot Below,

.<img width="738" alt="Screen Shot 2022-01-31 at 2 05 07 pm" src="https://user-images.githubusercontent.com/13806249/151773990-fe1f45cc-dfd2-4ec1-a6d7-f52d081c3d2b.png">

