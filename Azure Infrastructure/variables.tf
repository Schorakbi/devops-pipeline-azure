variable "my_public_ip_address" {
  description = "My public ip address."
  type        = string
}

variable "environment" {
  description = "Could be Testing, Development or Production environment."
  type        = string
}

variable "k8s_nodes" {
  description = "A list of k8s nodes (servers) which forms a cluster."
  type        = list(string)
}
variable "allowed_ports" {
  description = "A list of all allowed ports within a node."
  type        = list(string)
}

