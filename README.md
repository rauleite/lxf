# LXFramework
Um framework LXD que automatiza o *build machine* através de execução de comandos em série.

## Download e Install

```bash
git clone https://github.com/rauleite/lxf.git && cd lxf
./install.sh
cd ../ && sudo rm -r ./lxf #Opcional
```
*Para maiores detalhes sobre a instalação, paths e desinstação, [aqui](#detalhes-sobre-a-instalação)*

## Get started

Já tendo feito o `sudo lxd init`, como descrito na página de [configurações iniciais do lxd](https://stgraber.org/2016/03/15/lxd-2-0-installing-and-configuring-lxd-212/), basta criar o seguinte arquivo:

Crie o arquivo de exemplo: **`lxf-file.sh`**

```bash
# lxf-file.sh

# Configurações básicas
CONTAINER "app"
NETWORK "lxcbr0"
STORAGE_PATH "/var/lib/lxd/storage-pools/zfs/containers" # coloque o seu storage path

# Configuração avançada
CONFIG "set $CONTAINER security.privileged true"

# Imagem base
FROM ubuntu/zesty/amd64
 
# Executa comandos no container
EXEC apt-get install -y software-properties-common
```
No mesmo diretório, execute: `lxf file` 

Pronto, sua máquina será montada.

*Mais sobre execução e nome arquivo, [aqui](execução-do-arquivo)*

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
[ENV](#env)                 | Cria folder, com nome e grupo     | `<app_path_1> [<app_path_2>] ...[<app_path_10>]`
[EXEC](#exec)               | Executa comandos no container     | `EXEC <command>`
[FILES](#files)             | Executa arquivo no container      | `FILES <path_to_local_file>`
[FROM](#from)               | Imagem a ser usada                | `FROM <image>`
[HOST_EXEC](#host_exec)     | Executa comando no host           | `HOST_EXEC <command>`
[SOURCE](#source)           | Reaproveita outro lxf-file        | `SOURCE "<path-to-lxf-file>"`
[VOLUME](#volume)           | Arquivo e diretorio compartilhado | `VOLUME <local-path> <container-path>`


## Comandos Detalhados

### CONFIG
#### Sintaxe
```bash
CONFIG <lxc-config>
```
```bash
CONFIG "set app security.privileged true"
```

* Utilizado para setar qualquer [configuração lxd](https://github.com/lxc/lxd/blob/master/doc/configuration.md), junto à criação do container. Utiliza a mesma sintaxe.
* Pode repetir o commando **CONFIG** quantas vezes forem necessárias, para criação do container desejado.

#### Exemplo:
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
```
Exemplo prático
```bash
CONTAINER "app"

# Usando CONTAINER como referência
CONFIG "set $CONTAINER security.privileged true"

# FROM ...

# Neste ponto container app está criado
```

### COPY
```bash
COPY <host path> <container path>
```
Copia arquivo ou diretório, do host para o container.

##### Exemplo
```bash
COPY ./config/proxy/nginx.conf /etc/nginx/
COPY ./config/proxy/default /etc/nginx/sites-enabled/
```

### STORAGE_PATH
```bash
STORAGE_PATH "<path>"
```
Indique o local do seu Storage backends.
Por exemplo, o default path do ZFS é: **/var/lib/lxd/storage-pools/zfs/containers**

##### Exemplo
```bash
# Exemplo no caso do ZFS
STORAGE_PATH "/var/lib/lxd/storage-pools/zfs/containers"
```

### ENV
```bash
ENV "<app_path_1> [<app_path_2>] ...[<app_path_10>]"
```
**ENV** é um comando de conveniência para criação de um diretório (normalmente raiz das suas aplicações). Ele fará o seguinte:

1. Criará <app_path_1>, se ainda não existir...
    * Pseudo code:
        * `sudo mkdir -p <paths>`

1. com usuário e grupo indicado em `$USER_NAME` e `$USER_GROUP`...
    * Pseudo code:
        * `sudo chown $USER_NAME:$USER_GROUP <paths>`

2. e também vai setar este mesmo user e group como padrão, dos demais arquivos criados neste path.
    * Pseudo code:
        * `sudo chmod g+s <paths>`

##### Exemplo
```bash
# FROM ...
ENV "/var/www"

```
Exemplo prático:

```bash
VAR web_path "/var/www"
VAR server_path "/var/server"
# FROM ...

ENV "$web_path $server_path"
# Neste ponto já existe /var/www e /var/server

# ...

# Referenciando
COPY ./web/build $web_path/
COPY ./server/build $web_path/
```

### EXEC
```bash
EXEC <command>
```
Executa comandos no container

##### Exemplo
```bash
EXEC cd /var/server && yarn install

# Linha quebrada e com VAR
EXEC \
    cd $server_vm && \
    yarn start

```

### FILES
```bash
FILES <host_src_file.sh> [<resources_1.sh>] ...[<resources_10.sh>] <dest_path>
```

**FILES** é um comando de conveniência para execução de um arquivo, diretamente de dentro do próprio container.

O arquivo indicado será compiado para o container, e executado de dentro dele, considerando o devido `$USER_NAME`.

Se for passado mais de um arquivo, será compreendido que o primeiro é para execução, os intermediários são resources (utilizados por este primeiro), e o último é o path de destino dos arquivos.

##### Exemplo
```bash
FILES "/home/raul/dev/config/lxf/app.sh"
```

Exemplo prático:
```bash
USER_NAME "rauleite"
# ...

VAR server_host "/home/raul/server"
VAR src_dest "/home/$USER_NAME/src_dest"

# FROM ...

FILES \
    "$server_host/config/lxf/app.sh" \ # Este será executado
    "$server_host/config/lxf/src.sh" \ # Resource utilizado pelo app.sh
    "$server_host/config/lxf/lib-color.sh" \ # Idem src.sh
    "$src_dest" # Path destino destes arquivos. Se não existir, será criado
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