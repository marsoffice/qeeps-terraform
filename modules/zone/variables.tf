variable "location" {
  type = string
}

variable "env" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "app_name" {
  type = string
}

variable "secrets" {
  type = map(string)
}

variable "ad_application_id" {
  type = string
}

variable "ad_application_secret" {
  type      = string
  sensitive = true
}

variable "ad_audience" {
  type = string
}

variable "ad_issuer" {
  type = string
}

variable "internal_role_id" {
  type = string
}

variable "ad_application_object_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "is_main" {
  type = bool
}

variable "create_dev_resources" {
  type = bool
}

variable "other_sas" {
  type = map(any)
}

variable "other_signalr_connection_strings" {
  type = list(string)
}

variable "sbs_capacity" {
  type = number
}
variable "sbs_sku" {
  type = string
}
variable "appi_retention" {
  type = number
}
variable "appi_sku" {
  type = string
}
variable "signalr_capacity" {
  type = number
}
variable "signalr_sku" {
  type = string
}
variable "swa_sku_tier" {
  type = string
}
variable "swa_sku_size" {
  type = string
}
variable "all_locations" {
  type = map(string)
}
variable "cdb_multi_master" {
  type = bool
}
variable "marsoffice_sa_connection_string" {
  type = string
}
