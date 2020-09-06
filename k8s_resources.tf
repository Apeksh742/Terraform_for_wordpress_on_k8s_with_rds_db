resource "kubernetes_secret" "mysql" {
  metadata {
    name = "mysql-pass"
  }

  data = {
    password = var.mysql_password
    username = var.mysql_username
    dbname = var.mysql_db_name
    dbhost= aws_db_instance.DataBase.endpoint
  }
}

resource "kubernetes_deployment" "web_service" {
  depends_on = [aws_db_instance.DataBase]
  metadata {
    name = "wordpressdeployment"
    labels = {
      app = "wordpress"
      tier = "frontend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wordpress"
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
           app = "wordpress"
           tier = "frontend"
        }
      }

      spec {
        container {
           image = "wordpress"
           name  = "web-app"
           env  {
               name = "WORDPRESS_DB_HOST"
               value_from {
                 secret_key_ref {
                   name = kubernetes_secret.mysql.metadata[0].name
                   key  = "dbhost"
                 }
                }
               }  

           env  {
               name = "WORDPRESS_DB_PASSWORD"
               value_from {
                 secret_key_ref {
                   name = kubernetes_secret.mysql.metadata[0].name
                   key  = "password"
            }
          }
        }
               

           env  {
               name = "WORDPRESS_DB_USER"
                value_from {
                 secret_key_ref {
                   name = kubernetes_secret.mysql.metadata[0].name
                   key  = "username"
                 }
                }
           }

           env  {
               name = "WORDPRESS_DB_NAME"
               value_from {
                 secret_key_ref {
                   name = kubernetes_secret.mysql.metadata[0].name
                   key  = "dbname"
                 }
                }
           }

           port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "k8s_service" {
  depends_on = [kubernetes_deployment.web_service]
  metadata {
    name = "nodeportsvc"
  }
  spec {
    selector = {
      app = "wordpress"
      tier = "frontend"
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
