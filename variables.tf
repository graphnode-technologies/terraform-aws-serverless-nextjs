variable "domain_name" {

}

variable "zone_id" {

}

variable "alternative_names" {
  default = []
  type    = list(string)
}

variable "price_class" {
  default = "PriceClass_All"
}

variable "environment" {
  default = "development"
}

variable "tags" {
  default = {}
}
