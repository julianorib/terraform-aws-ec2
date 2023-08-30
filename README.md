# Criando uma Maquina Virtual na AWS com Terraform

Estou estudando Terraform a algum tempo e já fiz vários updates neste Projeto. 

- Primeiramente tenha uma conta na AWS.
- Crie um Usuário com o Privilégio (Administrator Access).
- Crie uma Chave de Acesso para este Usuario.
- Tenha ou Instale o Terraform no seu Computador.
- Tenha ou Instale o AWS Cli no seu Computador.


## Detalhes do Projeto

Este projeto cria os seguintes recursos:

- VPC
- 3 Subnets Publicas (1 em cada Zona de Disponibilidade)
- Internet Gateway
- Tabelas de Roteamento
- 3 Subnets Privadas (1 em cada Zona de Disponibilidade)
- 1 ou mais Máquinas Virtuais Ubuntu (EC2)
- Chave SSH (KeyPairs).
<br>
    Você tem que criar sua Chave antes (ssh-keygen) ou Utilizar uma existente.
- Security Groups (Acesso Internet e SSH)

- Mostra o IP Publico ao final

## Faça o clone para sua Estação

```
git clone https://github.com/julianorib/terraform-aws-ec2.git
```

## Ajustes no Projeto

Verificar as variáveis em *variables.tf* e defini-las em um novo arquivo *terraform.tfvars*

```
Tags
Tipo de instância
Região dos Recursos
Quantidade Vms (EC2)
CIDR VPC
```

## Autenticação no Provedor

Eu exporto as configurações de login e senha para criação dos Recursos.
Desta forma, não deixo fixo no projeto.

Linux:
```bash
export AWS_ACCESS_KEY_ID="Sua-Chave"
export AWS_SECRET_ACCESS_KEY="Sua-Senha"
```

Windows:
```Powershell
SET AWS_ACCESS_KEY_ID="Sua-Chave"
SET AWS_SECRET_ACCESS_KEY="Sua-Senha"
```


## Execute para Criação

```
terraform init
```

```
terraform apply
```

## Execute para Remoção

```
terraform destroy
```

## Imagens de Instalação (aws_ami)

Consultando Imagens Disponíveis por meio do AWS CLI:

Amazon
```
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[*].[CreationDate, ImageId, Name]" --output text
```
Windows
```
aws ec2 describe-images --filters "Name=name,Values=Windows*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[*].[CreationDate, ImageId, Name, OwnerId]" --output text
```
RedHat
```
aws ec2 describe-images --owners 309956199498 --filters "Name=name,Values=RHEL*x86_64*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[*].[CreationDate, ImageId, Name]" --output text
```
Ubuntu
```
aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/*amd64*" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "sort_by(Images, &CreationDate)[*].[CreationDate, ImageId, Name]" --output text
```


