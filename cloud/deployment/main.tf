# Access outputs from the infrastructure stage
data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "../infrastructure/terraform.tfstate"
  }
}

# Kubernetes provider configuration
provider "kubernetes" {

  host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_authority_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infrastructure.outputs.cluster_name]
    command     = "aws"
  }

}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_authority_ca)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.infrastructure.outputs.cluster_name]
      command     = "aws"
    }
  }
}



resource "kubernetes_manifest" "storage_class" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/storageclass.yaml"))


}


#PV

resource "kubernetes_persistent_volume" "pv" {
  metadata {
    name = var.pv_name
  }

  spec {
    storage_class_name = "efs-sc" # Reference the created StorageClass
    capacity = {
      storage = var.storage_size
    }
    persistent_volume_reclaim_policy = "Retain"
    access_modes                     = ["ReadWriteMany"]

    persistent_volume_source {
      nfs {
        #server = "${module.efs.efs_file_system_id}.efs.${var.region}.amazonaws.com" # Update with the correct output from your EFS module
        server = data.terraform_remote_state.infrastructure.outputs.efs_dns_name
        path   = "/"
      }
    }
  }

  # Ensure StorageClass exists before the PV is created
  depends_on = [kubernetes_manifest.storage_class]
}

#PVC
resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = var.pvc_name # Use the variable here
    namespace = "default"    # Specify the namespace if needed
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.storage_size # Use a variable for storage size
      }
    }
    storage_class_name = var.storage_class_name # Reference the StorageClass
  }

  # Ensure the PersistentVolume is created before the PVC
  depends_on = [kubernetes_persistent_volume.pv]
}

resource "kubernetes_manifest" "role" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/role.yaml"))

}

resource "kubernetes_manifest" "role_binding" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/role_binding.yaml"))

}

resource "kubernetes_manifest" "cluster_role" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/cluster_role.yaml"))

}

resource "kubernetes_manifest" "cluster_role_binding" {
  manifest   = yamldecode(file("${path.module}/k8s_manifest/cluster_role_binding.yaml"))
  depends_on = [kubernetes_manifest.cluster_role]
}

resource "kubernetes_manifest" "gpu_deployment" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/gpu-deployment.yaml"))
  field_manager {
    force_conflicts = true
  }

  depends_on = [kubernetes_persistent_volume_claim.pvc, resource.helm_release.gpu_operator]
}

resource "kubernetes_manifest" "gpu_service" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/gpu-service.yaml"))
}

resource "kubernetes_manifest" "cpu_deployment" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/cpu-deployment.yaml"))
  field_manager {
    force_conflicts = true
  }

  depends_on = [kubernetes_persistent_volume_claim.pvc]
}

resource "kubernetes_manifest" "cpu_service" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/cpu-service.yaml"))
}

resource "kubernetes_manifest" "ingress_resource" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/ingress-resource.yaml"))
  depends_on = [ data.kubernetes_service.nginx_ingress ]
}
resource "kubernetes_manifest" "pdb_default" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/pdb-default.yaml"))
  
}
resource "kubernetes_manifest" "pdb_kube-system" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/pdb-kube-system.yaml"))
  
}
resource "kubernetes_manifest" "hpa_gpu" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/hpa-gpu.yaml"))

  depends_on = [ kubernetes_manifest.gpu_deployment ]

}

resource "kubernetes_manifest" "hpa_cpu" {
  manifest = yamldecode(file("${path.module}/k8s_manifest/hpa-cpu.yaml"))
  depends_on = [ kubernetes_manifest.cpu_deployment ]
}


/********************************************
  GPU Operator Configuration
********************************************/
resource "helm_release" "gpu_operator" {
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = "v24.9.2"
  namespace        = "gpu-operator"
  create_namespace = true

}

/********************************************
  Node Feature Discovery Configuration
********************************************/
resource "helm_release" "nfd" {
  name             = "nfd"
  repository       = "https://kubernetes-sigs.github.io/node-feature-discovery/charts"
  chart            = "node-feature-discovery"
  version          = "0.17.2"
  namespace        = "node-feature-discovery"
  create_namespace = true

  set {
    name  = "worker.config.core.labelWhiteList"
    value = "node.kubernetes.io/instance-type=t3.medium*"
  }
}


/********************************************
 Nginx Ingress Controller
********************************************/

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.12.0"  # Specify the desired version
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "alb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }
}


resource "time_sleep" "wait_for_alb" {
  depends_on = [helm_release.nginx_ingress]
  create_duration = "120s"
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [time_sleep.wait_for_alb]
}




