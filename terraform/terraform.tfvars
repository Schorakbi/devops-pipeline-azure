my_public_ip_address = "197.15.78.203"
environment          = "Development"
allowed_ports        = ["25", "3000-10000", "80", "443", "22", "465", "30000-32767"]
vms_config = [
  {
    name          = "k8s-controller-node"
    type          = "k8s"
    ssh_key_path  = "~/.ssh/k8s-sshkey-1.pub"
    vm_size       = "Standard_B2s"
    template_file = "/template_files/k8s-setup.tpl"
  },
  {
    name          = "k8s-worker-node-1"
    type          = "k8s"
    ssh_key_path  = "~/.ssh/k8s-sshkey-2.pub"
    vm_size       = "Standard_B2s"
    template_file = "/template_files/k8s-setup.tpl"
  },
  {
    name          = "k8s-worker-node-2"
    type          = "k8s"
    ssh_key_path  = "~/.ssh/k8s-sshkey-3.pub"
    vm_size       = "Standard_B2s"
    template_file = "/template_files/k8s-setup.tpl"
  },
  {
    name          = "nexus-server"
    type          = "nexus"
    ssh_key_path  = "~/.ssh/nexus-sshkey.pub"
    vm_size       = "Standard_B2s"
    template_file = "/template_files/nexus-setup.tpl"
  },
  {
    name          = "jenkins-server"
    type          = "jenkins"
    ssh_key_path  = "~/.ssh/jenkins-sshkey.pub"
    vm_size       = "Standard_B2ms"
    template_file = "/template_files/jenkins-setup.tpl"
  },
  {
    name          = "sonarqube-server"
    type          = "sonarqube"
    ssh_key_path  = "~/.ssh/sonarqube-sshkey.pub"
    vm_size       = "Standard_B2s"
    template_file = "/template_files/sonarqube-setup.tpl"
  }
]
