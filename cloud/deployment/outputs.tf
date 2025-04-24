
# Manifest

output "pv_name" {
  value = kubernetes_persistent_volume.pv
}

output "storage_size" {
  value = kubernetes_persistent_volume_claim.pvc
}

output "pvc_name"{
    value = kubernetes_persistent_volume_claim.pvc
}

# output "ingress_hostname" {
#   value = length(data.kubernetes_service.my_service.status[0].load_balancer) > 0 && length(data.kubernetes_service.my_service.status[0].load_balancer[0].ingress) > 0 ? data.kubernetes_service.my_service.status[0].load_balancer[0].ingress[0].hostname : ""
# }
output "debug_nginx_ingress" {
  value = data.kubernetes_service.nginx_ingress
}

output "ingress_hostname" {
  description = "The external hostname of the Nginx Ingress Controller"
  value       = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
}


# output "nginx_ingress_lb_ip" {
#   value = data.kubernetes_service.nginx_ingress.status[0].load_balancer.ingress[0].ip
# }

