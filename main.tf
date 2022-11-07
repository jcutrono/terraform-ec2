provider "aws" { 
  region   = "us-east-1" 
}

resource "aws_key_pair" "key_pair_app" {
  key_name = "webapp_key_esep"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key_pair_app.key_name
  security_groups = ["a group with ssh and http"]
  tags = {
    Name = var.vmname
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa") 
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'download MS package'",
      "wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",

      "echo 'remove dotnet'",
      "sudo apt remove dotnet*",
      "sudo apt remove aspnetcore*",
      "sudo apt remove netstandard*",
      "sudo rm /etc/apt/sources.list.d/microsoft-prod.list",
      
      "echo 'install https'",
      "sudo apt-get update",      
      "sudo apt-get install -y apt-transport-https",
      
      "echo 'install niginx'",
      "sudo apt-get update",      
      "apt-get install nginx",

      "echo 'install dotnet'",
      "sudo apt-get update",
      "sudo apt-get install -y dotnet-sdk-6.0",

      "echo 'clone repo'",
      "sudo git clone https://github.com/jcutrono/terraform-ec2.git",
      "cd terraform-ec2",
      "sudo dotnet restore",
    ]
  }
}