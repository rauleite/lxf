# LXF Exemplo

## Objetivo
### Container

Será montado, de maneira interativa, um container com novo usuario no lugar do usuario "ubuntu" padrão. Este usuário estará pronto pra receber conexões ssh.

## Run:
`cd ./example/create_user`

`lxf create`

## Arquivos
* Principal: **`lxf-create.sh`**
* Script chamado pelo comando FILES: **`create.sh`**
* Resources usado pelo comando FILES: **`create_src.sh`**

**`lxf-create.sh`**
```bash
# Run with: lxf create

# CONTAINER omitido (sera considerado o nome arquivo: create).
# USER_NAME omitido (sera considerado o default: root).
# USER_GROUP omitido (sera considerado o default: root).

# Bridge usado (substitua pelo seu, criado normalmente pelo comando lxd init).
NETWORK    "lxcbr01"
# Garante acesso root.
PRIVILEGED "true"

VAR src_dest "/root/src_dest"

# STORAGE e STORAGE_PATH
# Deve ser usado apenas um ou outro. Não os dois juntos.

STORAGE "zfs" # coloque o nome do pool que voce criou (criado normalmente pelo comando lxd init).
# O valor do STORAGE_PATH abaixo, surtiria o mesmo efeito ao STORAGE acima.
# STORAGE_PATH "/var/lib/lxd/storage-pools/zfs/containers/$CONTAINER/rootfs"

# Usa imagem da sua maquina se houver, senão baixará antes.



# FROM ubuntu/zesty/amd64
FROM nodejs



# FILES e conveniente pra executar uma serie de comandos contidos em um arquivo.
FILES \
    "./create.sh" \
    "./create_src.sh" \
    "$src_dest"

# Restart CONTAINER, para garantir que todas as configurações feitas pelo 
# create.sh (setado em FILES) estejam em vigor 
SIGNAL "restart"

# Nome do grupo e usuario que defini durante create.sh (setado em FILES)
# Neste ponto será alterado de root (default), para rleite.
# Portanto todos os comandos realizados, serão efetuados pelo usuário rleite.
USER_NAME   "rleite"
USER_GROUP  "rleite"

# $USER_NAME (rleite) pode ser usado como referencia
VAR user_home /home/$USER_NAME
# $user_home tem o valor /home/rleite
EXEC ls -lha $user_home

# Instalando nodejs
# Note que pode por o comando direto, sem necessidade de envolver em strings, /bin/bash -c "", ou algo do tipo
# Neste caso poderia também ser outro FILES, setando arquivo que contenha sequencia 
# de comandos.
# Sintaxe: Também poderia fazer um comando EXEC por linha
EXEC \
    sudo apt-get update; \
    sudo apt-get upgrade; \
    which node &>/dev/null; \
    cd ~ && sudo rm -r n &>/dev/null; \ 
        git clone https://github.com/tj/n.git && cd n && \
            sudo make install; \
            sudo n ls &>/dev/null; \
            sudo n 8.5.0;

```