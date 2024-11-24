variable "my_public_ip_address" {
  description = "My public ip address."
  type        = string
}

variable "environment" {
  description = "Could be Testing, Development or Production environment."
  type        = string
}

variable "vms_config" {
  description = "A list of VM configurations required for the DevOps pipeline, including type (e.g., k8s, jenkins), SSH key paths, VM sizes, and names."
  type = list(object({
    name          = string # Name of the VM
    type          = string # Type of the VM (e.g., k8s, jenkins, nexus, etc.)
    ssh_key_path  = string # Path to the SSH key for the VM
    vm_size       = string # Size of the VM (e.g., Standard_F2, Standard_B1s)
    template_file = string # Path to the cloud-init or provisioning template file for the VM
  }))
}
variable "allowed_ports" {
  description = "A list of all allowed ports within a node."
  type        = list(string)
}
