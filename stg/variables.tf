variable "env" {
  type = string
  default = "stg"
}

variable "app_name" {
    type = string
    default = "qeeps"
}

variable "domain_name" {
  type = string
  default = "stg.qeeps.io"
}

variable "adminpassword" {
    type = string
    sensitive = true
}