output "vm_worker_ip" {
  description = "Public Ipv4 address of worker servers"
  value       = module.vm_worker.*.public_ip
}

output "vm_master_ip" {
  description = "Public Ipv4 address of master server"
  value       = module.vm_master.public_ip
}
