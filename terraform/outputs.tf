output "server_ip" {
  description = "Public IP of the k3s server"
  value       = hcloud_server.k3s_lab.ipv4_address
}

output "server_status" {
  description = "Status of the server"
  value       = hcloud_server.k3s_lab.status
}