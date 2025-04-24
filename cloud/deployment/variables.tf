

# Manifests

variable "pv_name" {
  description = "Name of the PersistentVolume"
  type        = string
  
}

variable "storage_size" {
  description = "Storage capacity of the PersistentVolume"
  type        = string
  
}

variable "pvc_name" {
  description = "Name of the PersistentVolume"
  type        = string
  
}
variable "storage_class_name" {
  description = "Name of the PersistentVolume"
  type        = string
}

variable "ml_backend_image" {
  description = "The Docker image for the ML backend"
  type        = string
}