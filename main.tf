terraform {
  required_version = "1.1.7"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.71.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

module "vm_manager" {
  source            = "./modules/module_instance"
  instancename      = "vmmanager"
  instance_hostname = "manager"
  subn_id           = yandex_vpc_subnet.foo.id
}

module "vm_worker" {
  count             = 2
  source            = "./modules/module_instance"
  instancename      = "vmworker-${count.index + 1}"
  instance_hostname = "worker-${count.index + 1}"
  subn_id           = yandex_vpc_subnet.foo.id
}

# Creating VPC and Subnets for Instances

resource "yandex_vpc_network" "foo" {
  name = "network1"
}

resource "yandex_vpc_subnet" "foo" {
  name           = "subnet_1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.foo.id
  v4_cidr_blocks = ["10.2.0.0/16"]
}

data "template_file" "ansible_inventory" {
  template = file("hosts.txt.tpl")
  vars = {
    vm_worker1 = module.vm_worker.0.public_ip
    vm_worker2 = module.vm_worker.1.public_ip
    vm_manager  = module.vm_manager.public_ip
  }

}

resource "null_resource" "update_inventory" {
  triggers = {
    template = data.template_file.ansible_inventory.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_inventory.rendered}' > hosts.txt"
  }
}
