provider "kubernetes" {
  config_context = "minikube"
}

provider "aws" {
   region = "ap-south-1"
   profile = "apeksh"
}