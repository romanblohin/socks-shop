[worker_servers]
vm_worker1 ansible_host=${vm_worker1}
vm_worker2 ansible_host=${vm_worker2}
[manager_servers]
vm_manager ansible_host=${vm_manager}

[all_servers:children]
worker_servers
manager_servers

[all_servers:vars]
ansible_user=ubuntu
