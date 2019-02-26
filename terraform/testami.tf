# Test Packer ami image

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "packer_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["packer-jenkins*"]
  }

  owners = ["602530222609"]   # update this id
}

variable "PATH_TO_PUBLIC_KEY" {
	default= "./key/tmpkey.pub"
}

resource "aws_key_pair" "tmpkey" {
	#key_name = "tmpkey"
	public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "test_ami" {
  ami           = "${data.aws_ami.packer_ami.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.tmpkey.key_name}" 
  
  tags {
    Name = "TestAMI-Packer"
  }
}

output "packer_ami_id" { 
  value = "${data.aws_ami.packer_ami.id}"
}

output "ec2_public_ip" { 
  value = "${aws_instance.test_ami.public_ip}"
}
