variable "org_name" {
  type     = string
  nullable = false
}

variable "container_name" {
  type    = string
  default = "meteor-challenge-app"
}

variable "container_port" {
  type    = number
  default = 3000
}
