locals {
  common_tags = {
    projeto  = var.Name
    ambiente = var.tag-ambiente
    dono     = var.tag-dono
    ccusto   = var.tag-ccusto
  }
}
