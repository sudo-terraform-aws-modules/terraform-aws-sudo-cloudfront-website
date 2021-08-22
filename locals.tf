locals {
  mime_types = jsondecode(file("${path.module}/files/mime.json"))
}