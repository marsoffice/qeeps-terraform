terraform {
  backend "azurerm" {
    resource_group_name  = "rg-marsoffice"
    storage_account_name = "samarsoffice"
    container_name       = "tfstates"
    key                  = "qeeps.stg.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.14.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {

}

module "sa_marsoffice" {
  source         = "../modules/data-sa"
  resource_group = "rg-marsoffice"
  name           = "samarsoffice"
}


module "rg" {
  source   = "../modules/rg"
  location = "West Europe"
  name     = "rg-${var.app_name}-${var.env}"
}


module "ad_app" {
  source                     = "../modules/ad-app"
  name                       = var.domain_name
  redirect_url               = "app.${var.domain_name}"
  include_localhost_redirect = true
  logo_b64                   = filebase64("${path.root}/../resources/ad_app.png")
  price_per_month = 40
}

module "cdb" {
  source         = "../modules/cdb"
  resource_group = module.rg.name
  name           = "cdb-${var.app_name}-${var.env}"
  free           = true
  locations      = [module.rg.location]
  multi_master   = false
  serverless     = true
}

locals {
  secrets = tomap({
    adminpassword       = var.adminpassword,
    adapplicationsecret = module.ad_app.application_secret,
    cdbconnectionstring = module.cdb.connection_string,
    publicvapidkey      = var.publicvapidkey
    privatevapidkey     = var.privatevapidkey,
    sendgridapikey      = var.sendgridapikey,
    adminemails         = var.adminemails,
    opaurl = var.opaurl,
    opatoken = var.opatoken
  })
}

module "zone_westeurope" {
  source                   = "../modules/zone"
  location                 = "West Europe"
  resource_group           = module.rg.name
  app_name                 = var.app_name
  env                      = var.env
  secrets                  = local.secrets
  ad_application_id        = module.ad_app.application_id
  ad_application_secret    = module.ad_app.application_secret
  ad_audience              = module.ad_app.audience
  ad_issuer                = module.ad_app.issuer
  internal_role_id         = module.ad_app.internal_role_id
  ad_application_object_id = module.ad_app.sp_object_id
  domain_name              = var.app_hostname
  is_main                  = true
  create_dev_resources     = true
  other_sas = tomap({
    #westus = module.zone_westus2.sa
  })
  other_signalr_connection_strings = [
    #module.zone_westus2.signalr.connection_string
  ]
  sbs_capacity                    = 0
  sbs_sku                         = "Basic"
  signalr_capacity                = 1
  signalr_sku                     = "Free_F1"
  swa_sku_size                    = null
  swa_sku_tier                    = "Free"
  appi_retention                  = 30
  appi_sku                        = "PerGB2018"
  all_locations                   = var.all_locations
  cdb_multi_master                = module.cdb.multi_master
  marsoffice_sa_connection_string = module.sa_marsoffice.connection_string
}

# module "zone_westus2" {
#   source                   = "../modules/zone"
#   location                 = "West US 2"
#   resource_group           = module.rg.name
#   app_name                 = var.app_name
#   env                      = var.env
#   secrets                  = local.secrets
#   ad_application_id        = module.ad_app.application_id
#   ad_application_secret    = module.ad_app.application_secret
#   ad_audience              = module.ad_app.audience
#   ad_issuer                = module.ad_app.issuer
#   internal_role_id         = module.ad_app.internal_role_id
#   ad_application_object_id = module.ad_app.sp_object_id
#   domain_name              = var.app_hostname
#   is_main                  = false
#   create_dev_resources     = false
#   other_sas = tomap({
#     westeurope = module.zone_westeurope.sa
#   })
#   other_signalr_connection_strings = [
#     module.zone_westeurope.signalr.connection_string
#   ]
#   sbs_capacity     = 0
#   sbs_sku          = "Basic"
#   signalr_capacity = 1
#   signalr_sku      = "Free_F1"
#   swa_sku_size     = null
#   swa_sku_tier     = "Free"
#   appi_retention   = 30
#   appi_sku         = "PerGB2018"
#   all_locations    = var.all_locations
#   cdb_multi_master = module.cdb.multi_master
#   marsoffice_sa_connection_string = module.sa_marsoffice.connection_string
# }

# module "fd" {
#   source                = "../modules/fd"
#   resource_group        = module.rg.name
#   name                  = "fd-${var.app_name}-${var.env}"
#   cname                 = var.app_hostname
#   health_probe_interval = 120
#   swa_hostnames = [
#     module.zone_westeurope.swa_hostname,
#     module.zone_westus2.swa_hostname
#   ]

#   depends_on = [
#     module.dns
#   ]
# }
