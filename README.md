# LXFramework
Um framework LXD que automatiza o *build machine* através de execução de comandos em série.

## Download e Install

```bash
git clone https://github.com/rauleite/lxf.git && cd lxf
./install.sh
cd ../ && sudo rm -r ./lxf #Opcional
```
*Para maiores detalhes sobre a instalação, paths e desinstação, [aqui](detalhes-sobre-a-instalação)*

## Get started

Já tendo feito o `sudo lxd init`, como descrito na página de [configurações iniciais do lxd](https://stgraber.org/2016/03/15/lxd-2-0-installing-and-configuring-lxd-212/), basta criar o seguinte arquivo:

Crie arquivo: **`lxf-file.sh`**

```bash
# lxf-file.sh

# Configurações básicas
CONTAINER "app"
NETWORK "lxcbr0"

# Configuração avançada
CONFIG "set $CONTAINER security.privileged true"

# Imagem base
FROM ubuntu/zesty/amd64
 
# Executa comandos no container
EXEC apt-get install -y software-properties-common
```
No mesmo diretório, execute:

`lxf file` 

Pronto, sua máquina será montada.

*Mais sobre execução pelo nome arquivo, [aqui](execução-do-arquivo)*

Sessões do manual
---
### Tabela Rápida
* [Comandos de criação](#comandos-de-criação)
* [Comandos de execução](#comandos-de-execução)

### Todos os comandos
* [CONFIG](#config)
* [CONTAINER](#container)
* [COPY](#copy)
* [ENV](#env)
* [EXEC](#exec)
* [FILES](#files)
* [FROM](#from)
* [HOST_EXEC](#host_exec)
* [SOURCE](#source)
* [STORAGE_PATH](#dest_path)
* [IPV4](#ipv4)
* [NETWORK](#network)
* [PRIVILEGED](#privileged)
* [USER_NAME](#user_name)
* [USER_GROUP](#user_group)
* [VAR](#var)
* [VOLUME](#volume)


## Tabela rápida de comandos

### Comandos de Criação

São chamado comandos de criação, aqueles utilizados para configuração pré criação do container. Normalmente ficam ficam dispostos nas linhas antes do comando **FROM**.

Também é possível referenciá-los pelos outros comandos, mais comumente pelo comando **CONFIG**.

##### Exemplo:
```bash
# Comandos de criação
CONTAINER "app"

CONFIG "set $CONTAINER security.privileged true"

# FROM ...
```

Comando                     | Descrição                             | Sintaxe
:--                         | :--                                   | :--
[CONFIG](#config)           | Qualquer [configuração lxd](https://github.com/lxc/lxd/blob/master/doc/configuration.md)   | `CONFIG <lxc-config>`
[CONTAINER](#container)         | Nome do container                 | `CONTAINER "<name>"`
[STORAGE_PATH](#storage_path)   | Path do Storage                   | `STORAGE_PATH "<path>"`
[IPV4](#ipv4)                   | Alias para ipv4 config            | `IPV4 <ip.fixo.do.container>`
[NETWORK](#network)             | Nome do device para brigde        | `NETWORK <nome do device>`
[PRIVILEGED](#privileged)       | Alias para privileged config      | `PRIVILEGED "<true|false>"`
[USER_NAME](#user_name)         | User assumido para os comandos    | `USER_NAME "<name>"`
[USER_GROUP](#user_group)       | Group assumido para os comandos   | `USER_GROUP "<group>"`
[VAR](#var)                     | Define variáveis                  | `VAR <key> "<value>"`

### Comandos de Execução

São chamados comandos de execução aqueles que rodam logo após o container ser criado. Pode ser entendido que são basicamente aqueles dispostos nas linhas após o comando **FROM**.

```bash
# ...

# FROM ...

# Comandos de execução
EXEC apt-get install -y software-properties-common
```

Comando                     | Descrição                         | Sintaxe
:--                         | :--                               | :--
[COPY](#copy)               | Copia host -> container           | `COPY <host path> <container path>`
[ENV](#env)                 | Cria folder, com nome e grupo     | `ENV "app_path_1 app_path_2"`
[EXEC](#exec)               | Executa comandos no container     | `EXEC <command>`
[FILES](#files)             | Executa arquivo no container      | `FILES <path_to_local_file>`
[FROM](#from)               | Imagem a ser usada                | `FROM <image>`
[HOST_EXEC](#host_exec)     | Executa comando no host           | `HOST_EXEC <command>`
[SOURCE](#source)           | Reaproveita outro lxf-file        | `SOURCE "<path-to-lxf-file>"`
[VOLUME](#volume)           | Arquivo e diretorio compartilhado | `VOLUME <local-path> <container-path>`


## Comandos Detalhados

#### CONFIG
```bash
CONFIG <lxc-config>
```
* Utilizado para setar qualquer [configuração lxd](https://github.com/lxc/lxd/blob/master/doc/configuration.md), junto à criação do container.
* Pode repetir o commando **CONFIG** quantas vezes forem necessárias, para criação do container desejado.

##### Exemplo:
```bash
CONTAINER "app"
NETWORK "lxcbr0"

# ...

### CONFIG ###
# Setando privileged true
CONFIG "set $CONTAINER security.privileged true"
# Setando IPV4 fixo
CONFIG "device set $CONTAINER $NETWORK ipv4.address 10.99.125.10"

# FROM ...
```

### CONTAINER
```bash
CONTAINER "<name>"
```

* Nome atribuido ao container
* Se não existir container com este nome, um novo será criado. Caso contrário utilizará o container existente.
* O comando **CONTAINER** também pode ser utilizado como variável no corpo do arquivo:

##### Exemplo:
```bash
CONTAINER "app"
# ...
CONFIG "set $CONTAINER security.privileged true"

# FROM ...
```

### COPY
```bash
COPY <host path> <container path>
```
Copia arquivo ou diretório, do host para o container.

##### Exemplo
```bash

```

### STORAGE_PATH
```bash
`STORAGE_PATH "<path>"`
```

##### Exemplo
```bash

```

### ENV
```bash

```

##### Exemplo
```bash

```

### EXEC
```bash

```

##### Exemplo

### FILES
```bash

```

##### Exemplo
```bash

```

### FROM
```bash

```

##### Exemplo
```bash

```

### HOST_EXEC
```bash

```

##### Exemplo
```bash

```

### IPV4
```bash

```

##### Exemplo
```bash

```

### NETWORK
```bash

```

##### Exemplo
```bash

```

### PRIVILEGED
```bash

```

##### Exemplo
```bash

```

### SOURCE
```bash

```

##### Exemplo
```bash

```

### USER_NAME
```bash

```

##### Exemplo
```bash

```

### USER_GROUP
```bash

```

##### Exemplo
```bash

```

### VAR
```bash

```

##### Exemplo
```bash

```

### VOLUME
```bash

```

##### Exemplo
```bash

```

## Execução do arquivo
A extensão **.sh** é opcional (use para usufruir da colorização dos editores). Pode deixar sem nenhuma extensão se preferir.

Todas as seguintes maneiras de chamar o arquivo **`lxf-file.sh`**, são válidas:

* `lxf file` (sem lxf e .sh) 
* `lxf lxf-file.sh` (nome do arquivo completo)
* `lxf file.sh` (sem lxf)
* `lxf lxf-file` (sem .sh)

## Detalhes sobre a instalação
A instalação nada mais é do que alguns arquivos que são incluidos em seus respectivos paths. Sem alterações em arquivos como ~/.bashrc ou qualquer outro. A remoção, é a exclusão destes.

Default path do src e bin
* **/usr/local/src**
* **/usr/local/bin**

### Alterar Paths

Para facilitar o manuseio, não é utilizado variáveis de ambiente. Portanto, basta alterar o path em dois arquivos:

1. Em **./src_install.sh**
    ```bash
    declare -r SRC_PATH="/usr/local/src"
    declare -r BIN_PATH="/usr/local/bin"
    ```

1. Em **./bin/lxf.sh**
    ```bash
    declare -r SRC_PATH="/usr/local/src"
    ```

### Uninstall

Para desinstalar: 
```bash
./uninstall
```
ou *(caso não tenha mais os resources baixado)*
```bash
git clone https://github.com/rauleite/lxf.git && cd lxf && ./uninstall.sh && cd ../ && sudo rm -r ./lxf
```
Obs. Mesmo no caso de ter customizado o Path ao instalar, o comando acima é suficiente pra remover os arquivos corretos.