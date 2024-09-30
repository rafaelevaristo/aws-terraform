resource "null_resource" "health_check" {
    provisioner "local-exec" {
      
      # command = "echo $FOO $BAR $BAZ >> env_vars.txt"

    command = "/bin/bash healthcheck.sh"

      environment = {
        DESTINATION = "jsonplaceholder.typicode.com"
        BAR = 1
        BAZ = "true"
      }
    }


}

# resource "null_resource" "health_check" {

#  provisioner "local-exec" {

#     command = "/bin/bash healthcheck.sh"



#   }
# }





output hello1 {
    value = "Hello World 1234"
}


#https://www.pluralsight.com/resources/blog/cloud/deploying-apps-terraform-aws