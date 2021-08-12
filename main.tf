# Accessing the provider
provider "aws" {
    access_key = "AKIA3ZHUTQOV6JVLUGUS"
    secret_key = "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"
    region = "us-west-2"
  
}
# Creating the VPC
resource "aws_vpc" "vpc" {
        cidr_block = "10.0.0.0/16"
        enable_dns_hostnames = true
        enable_dns_support = true
        tags = {
            "Name" = "main"
        }
}
# Creating the internet gateway
resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id	


     tags = {
	 "Name" = "vpc_igw"
 }
}
# Creating the public subnet
resource "aws_subnet" "public"{
        cidr_block = "10.0.1.0/24"
        map_public_ip_on_launch = true
	vpc_id = aws_vpc.vpc.id
	availability_zone = "us-west-2a"
        tags = {
            "Name" = "instance"
        }
}
# Creating the custom route table 
resource "aws_route_table" "public_rt" {
        vpc_id = aws_vpc.vpc.id 

        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.igw.id
           }
   
        tags = {
            "Name" = "public_rt"
        }   
}
# Associating the subnet with public_rt
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Creating the security group
resource "aws_security_group" "allow_tls" {
	  name        = "allow_ssh"
  	  description = "Allow _ssh"
	  vpc_id = aws_vpc.vpc.id

	  ingress {
	     description = "SSH"
	     from_port = 22
	     to_port   = 22
	     protocol = "tcp"
	     cidr_blocks = ["0.0.0.0/0"]
          }
	  egress {
	    from_port = 0
	    to_port = 0
            protocol = "-1"
	    cidr_blocks = ["0.0.0.0/0"]
       }
}

# Creating the private subnet

resource "aws_subnet" "private_sub" {
	vpc_id = aws_vpc.vpc.id
	cidr_block = "10.0.2.0/24"
	availability_zone = "us-west-2b"
  	tags = {
   	  "Name" = "private_sub"
    }
}
# Creating the public instance

resource "aws_instance" "public_inst" {
	ami = "ami-04b6c97b14c54de18"
	subnet_id = aws_subnet.public.id
	#map_public_ip_on_launch = true
	key_name = "chinnu"
	security_groups = [aws_security_group.allow_tls.id]
	instance_type = "t2.micro"
	tags = {
	  "Name" = "public_inst1"
        }
}
# Create the EIP

resource "aws_eip" "nat1" {
	depends_on = [aws_internet_gateway.igw]
}
# Creating the aws nat gateway

resource "aws_nat_gateway" "gw1" {
	allocation_id = aws_eip.nat1.id
	subnet_id = aws_subnet.private_sub.id
	tags = {
          "Name" = "NAT1"
        }
}
# Creating the custom rt for private

resource "aws_route_table" "privte_rt" {
	vpc_id = aws_vpc.vpc.id
	route {
	  cidr_block = "0.0.0.0/0"
	  nat_gateway_id = aws_nat_gateway.gw1.id
	}
	tags = {
	  "Name" = "private_rt"
	}
}
# Creating the security group for private 
resource "aws_security_group" "private_sg" {
	name        = "allow_ssh"
          description = "Allow _ssh"
          vpc_id = aws_vpc.vpc.id

          ingress {
             description = "SSH"
             from_port = 22
             to_port   = 22
             protocol = "tcp"
             cidr_blocks = ["aws_security_group.allow_tls"]
          }
          egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
       }
}
