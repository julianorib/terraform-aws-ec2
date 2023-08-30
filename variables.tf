variable "Name" {
  type        = string
  description = "Nome do projeto"
  default     = "Exemplo"
}

variable "tag-dono" {
  type        = string
  description = "Dono do projeto"
  default     = "Dono"
}

variable "tag-ambiente" {
  type        = string
  description = "Ambiente do projeto"
  default     = "Testes"
}

variable "tag-ccusto" {
  type        = string
  description = "Centro de Custo do projeto"
  default     = "Tecnologia"
}

variable "instance_type" {
  type        = string
  description = "Tipo de Maquina Virtual"
  default     = "t2.micro"
}

variable "regiao" {
  type        = string
  description = "Região dos Recursos"
  default     = "us-east-2"
}

variable "qtdevm" {
  type        = number
  description = "Quantidade de Maquinas Virtuais"
  default     = 1
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "subnet-public" {
  default = [
    { regiao = "a", subnet = "1" },
    { regiao = "b", subnet = "3" },
    { regiao = "c", subnet = "5" },
  ]
}

variable "subnet-private" {
  default = [
    { regiao = "a", subnet = "2" },
    { regiao = "b", subnet = "4" },
    { regiao = "c", subnet = "6" },
  ]
}
