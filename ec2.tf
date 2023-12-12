 data "aws_ami" "ami" {
  most_recent       = true
  name_regex        = "centos7-with-ansible"   # Ensure you use the IMage with Ansible Installed
  owners            = ["355449129696"]
}
 
resource "aws_instance" "instance" {

  ami                       = data.aws_ami.ami.id
  instance_type             = var.instance_type
  vpc_security_group_ids    = var.sgid

  tags = {
        Name       = var.name
    }
}

resource "aws_route53_record" "www" {

  depends_on = [aws_instance.instance]

  zone_id  = var.zone_id
  name     = var.name
  type     = "A"
  ttl      = 10
  records  = [aws_instance.instance.private_ip]
}


# Installing the applicaiton
resource "null_resource" "app" {

  triggers = {
    always_run = "${timestamp()}"                      # This ensure your provisoner would be execuring all the time,
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }
    inline = [
        "sleep 30",
        "COMPONENT=${var.name}",
        "COMP=$(echo ${var.name} | sed 's/-dev//g')",
        "SQL_PSW=RoboShop@1",
        "ansible-pull -U https://github.com/b56-clouddevops/ansible.git -e ENV=dev -e COMPONENT=$COMP -e MYSQL_PSW=${var.MYSQL_PSW} roboshop-pull.yml"
    ]
  }
}