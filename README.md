# LXFramework
Um framework LXD que automatiza o *build machine* através de execução de comandos em série.

Download e Install
---
```
git clone https://github.com/rauleite/lxf.git && cd lxf
./install.sh

# Opcional:
cd ../ && rm -r ./lxf
```
#### Default Paths:
* Source: */usr/local/src*
* Bin:    */usr/local/bin*

Como [alterar default paths](#alterar-paths).

Como [desinstalar](#uninstall).


### Alterar Paths ###
Para facilitar o manuseio, não é utilizado variáveis de ambiente. Portanto, basta alterar o path em dois arquivos:

1. Em *./install.sh*
    ```
    declare -r SRC_PATH="/usr/local/src"
    declare -r BIN_PATH="/usr/local/bin"
    ```

1. Em *./bin/lxf.sh*
    ```
    # declare -r SRC_PATH="/usr/local/src"
    ```

### Uninstall ###
Para desinstalar: 
```
./uninstall
```
ou *(caso não tenha mais os resources baixado)*
```
git clone https://github.com/rauleite/lxf.git && cd lxf && ./uninstall.sh && cd ../ && sudo rm -r ./lxf
```
Obs. Mesmo no caso de ter customizado o Path ao instalar, o comando acima é suficiente pra remover os arquivos corretos.