# Run with: lxf create
# Vai criar um container com o nome padrao (create)

NETWORK    "lxcbr01"
PRIVILEGED "true"

VAR src_dest "/root/src_dest"

# Usa da sua maquina, ou baixa
FROM ubuntu/zesty/amd64

STORAGE_PATH "/var/lib/lxd/storage-pools/zfs/containers/$CONTAINER/rootfs" # coloque o seu storage path

# FILES e conveniente pra executar uma serie de comandos contida em um arquivo

# Daria no mesmo que fazer algo como:
# EXEC apt-get install -y build-essential
# EXEC apt-get install -y openssh-server
# etc...

# Ou então:
# EXEC apt-get install -y perl-modules; \
#   apt-get install -y rsync
# etc...

FILES \
    "./create.sh" \
    "./create_src.sh" \
    "$src_dest"


