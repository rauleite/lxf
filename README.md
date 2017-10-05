# LXFramework
Um framework LXD que automatiza o *build machine* através de execução de comandos em série.

Download e Install
---
```
git clone https://github.com/rauleite/lxf.git && cd lxf
./install.sh
cd ../ && sudo rm -r ./lxf #Opcional
```
#### Default Paths:
* Source: */usr/local/src*
* Bin:    */usr/local/bin*

Como [alterar default paths](#alterar-paths).

Como [desinstalar](#uninstall).

Get started
---
```
# Configurações básicas
CONTAINER "app"
NETWORK "lxcbr01"

# Configuração avançada
CONFIG "set $CONTAINER security.privileged true"

# Usa local (se houver), ou baixa
FROM ubuntu/zesty/amd64

# Executa comandos no container
EXEC ls
```

Comandos
---
Comando                     | Descrição                         | Syntax
:--                         | :--                               | :--
[CONFIG](#config)           | Qualquer configuração lxc         | `CONFIG <lxc-config>`
[CONTAINER](#container)     | Nome do container                 | `CONTAINER <name>`
[COPY](#copy)               | Copia host -> container           | `COPY <host path> <container path>`
[DEST_PATH](#dest_path)     | Path do                           | `DEST_PATH "<path>"`
[ENV](#env)                 | Cria folder, com nome e grupo     | `ENV "app_path_1 app_path_2"`
[EXEC](#exec)               | Executa comandos no container     | `EXEC <command>`
[FILES](#files)             | Executa arquivo no container      | `FILES <path_to_local_file>`
[FROM](#from)               | Imagem a ser usada                | `FROM <image>`
[HOST_EXEC](#host_exec)     | Executa comando no host           | `HOST_EXEC <command>`
[IPV4](#ipv4)               | Alias para ipv4 config            | `IPV4 <ip.fixo.do.container>`
[NETWORK](#network)         | Nome do device para brigde        | `NETWORK <nome do device>`
[PRIVILEGED](#privileged)   | Alias para privileged config      | `PRIVILEGED "<true|false>"`
[SOURCE](#source)           | Reaproveita outro lxf-file        | `SOURCE "<path-to-lxf-file>"`
[USER_NAME](#user_name)     | User assumido para os comandos    | `USER_NAME "<name>"`
[USER_GROUP](#user_group)   | Group assumido para os comandos   | `USER_GROUP "<group>"`
[VAR](#var)                 | Define variáveis                  | `VAR <key> "<value>"`
[VOLUME](#volume)           | Arquivo e diretorio compartilhado | `VOLUME <local-path> <container-path>`

Comandos Detalhados
---
#### CONFIG

#### CONTAINER

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
    ```
    declare -r SRC_PATH="/usr/local/src"
    declare -r BIN_PATH="/usr/local/bin"
    ```

1. Em **./bin/lxf.sh**
    ```
    declare -r SRC_PATH="/usr/local/src"
    ```

Uninstall
---

Para desinstalar: 
```
./uninstall
```
ou *(caso não tenha mais os resources baixado)*
```
git clone https://github.com/rauleite/lxf.git && cd lxf && ./uninstall.sh && cd ../ && sudo rm -r ./lxf
```
Obs. Mesmo no caso de ter customizado o Path ao instalar, o comando acima é suficiente pra remover os arquivos corretos.