# LXFramework
Um framework LXD que automatiza o *build machine* através de execução de comandos em série.

Download e Install
---
```bash
git clone https://github.com/rauleite/lxf.git && cd lxf
./install.sh
cd ../ && sudo rm -r ./lxf #Opcional
```
#### Default Paths
Segue local padrão do src e bin
* **/usr/local/src**
* **/usr/local/bin**

Como [alterar default paths](#alterar-paths).

Como [desinstalar](#uninstall).

Get started
---
```bash
# Arquivo: lxf-file.sh

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
#### Maneiras de execução:
No mesmo diretório do arquivo (lxf-file.sh, no caso acima), execute:
```bash
lxf file
``` 
#### Notas:
1. A extensão **.sh** é opcional (use em caso de preferir pela colorização dos editores). Pode deixar sem nenhuma extensão se preferir.
1. Durante o comando ( `lxf file` ), note que não precisa digitar a parte **lxf-** do começo arquivo, e nem **.sh** do final.

Todas as seguintes maneiras de chamar o arquivo, são válidas:
* `lxf file` (mais simples) 
* `lxf lxf-file.sh` (nome do arquivo completo)
* `lxf file.sh` (sem lxf)
* `lxf lxf-file` (sem .sh)

Sessões do tutorial
---
### Tabela Rápida
* [Comandos de configuração](#comandos-de-criacao)
* [Comandos de execução](#comandos-de-execucao)

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


Tabela rápida de comandos
---

## Comandos de Criação

São chamado comandos de criação, aqueles utilizados para configuração pré criação do container. Normalmente ficam ficam dispostos nas linhas antes do comando **FROM**.

Também é possível referenciá-los pelos outros comandos, mais comumente pelo comando **CONFIG**.

##### Exemplo:
```bash
# Comandos de criação
CONTAINER "app"

CONFIG "set $CONTAINER security.privileged true"

# FROM ...
```

Comando                     | Descrição                         | Sintaxe
:--                         | :--                               | :--
[CONFIG](#config)           | Qualquer [configuração lxd](https://github.com/lxc/lxd/blob/master/doc/configuration.md)   | `CONFIG <lxc-config>`
[CONTAINER](#container)     | Nome do container                 | `CONTAINER <name>`
[STORAGE_PATH](#dest_path)  | Path do Storage                   | `STORAGE_PATH "<path>"`
[IPV4](#ipv4)               | Alias para ipv4 config            | `IPV4 <ip.fixo.do.container>`
[NETWORK](#network)         | Nome do device para brigde        | `NETWORK <nome do device>`
[PRIVILEGED](#privileged)   | Alias para privileged config      | `PRIVILEGED "<true|false>"`
[USER_NAME](#user_name)     | User assumido para os comandos    | `USER_NAME "<name>"`
[USER_GROUP](#user_group)   | Group assumido para os comandos   | `USER_GROUP "<group>"`
[VAR](#var)                 | Define variáveis                  | `VAR <key> "<value>"`

## Comandos de Execução

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


Comandos Detalhados
---
#### CONFIG
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

#### CONTAINER
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

#### COPY

#### DEST_PATH

#### ENV

#### EXEC

#### FILES

#### FROM

#### HOST_EXEC

#### IPV4

#### NETWORK

#### PRIVILEGED

#### SOURCE

#### USER_NAME

#### USER_GROUP

#### VAR

#### VOLUME

Alterar Paths
---

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

Uninstall
---

Para desinstalar: 
```bash
./uninstall
```
ou *(caso não tenha mais os resources baixado)*
```bash
git clone https://github.com/rauleite/lxf.git && cd lxf && ./uninstall.sh && cd ../ && sudo rm -r ./lxf
```
Obs. Mesmo no caso de ter customizado o Path ao instalar, o comando acima é suficiente pra remover os arquivos corretos.