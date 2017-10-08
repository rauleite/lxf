#!/bin/bash

# Vai instalar alguns essenciais, deletar usuario ubuntu padrão, criar um novo interativamente,
# e deixar ele pronto para receber conexão SSH

# Source referenciado no comando FILES
source ./create_src.sh

exit 0

apt-get install -y build-essential
apt-get install -y openssh-server
apt-get install -y perl-modules
apt-get install -y rsync

echo_quest "Vai querer auditar esta vm (container) [yN]?"
read audit
if [[ $audit =~ ^[yY][[:blank:]]*$ ]]
then
    apt-get install -y software-properties-common
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F
    add-apt-repository "deb [arch=amd64] https://packages.cisofy.com/community/lynis/deb/ xenial main"
    update
    apt-get install -y lynis
fi

echo_info "Removendo user padrao: ubuntu"
deluser --remove-home --remove-all-files ubuntu &>/dev/null

echo_quest "Qual o nome do novo usuario?"
read user_name

[[ ! -z $user_name ]] || ( echo "Tem que ter novo usuario" && exit 1 )

adduser $user_name --disabled-password
passwd -d $user_name

echo_quest "Copie a linha abaixo:"
echo_code "$user_name ALL=NOPASSWD: ALL"
echo_quest "Cole na ultima linha do editor, que abrira em seguida. Salve e saia do editor."
echo_quest "Copiou? [Enter]"
read ok
visudo

echo_info "Instrucoes para remover o acesso ssh via root:"
echo_quest "Copie as linhas abaixo, do jeito que esta (com espacos tambem):"
echo_code "X11Forwarding no
PasswordAuthentication no

Match User root
    PasswordAuthentication yes"
echo_quest "Cole no final do arquivo, depois salve e saia do editor (que se abrira):"
echo_quest "Copiou? [Enter]"
read ok

vi /etc/ssh/sshd_config #(note a letra 'd', no 'sshd_config'.)
service sshd restart
sshd -t


echo_info "Gere as keys (ATENCAO: SOMENTE no caso de ainda nao ter)."
echo_quest "Faça os comandos abaixo na sua maquina (host), em outro terminal:"
echo_quest "Opcional:"
echo_code "ssh-keygen -t rsa"
echo_quest "Obrigatorio:"
echo_code "cat ~/.ssh/id_rsa.pub #Troque pelo caminho da key, caso esteja em outro diretorio."
echo_quest "Copie a key que acabou de imprimir no terminal, cole no editor que abrira, salve e saia"
echo_quest "Gerou a chave (se necessario) e copiou [Enter]?"
read ok

mkdir -p /home/$user_name/.ssh
touch /home/$user_name/.ssh/authorized_keys
vi /home/$user_name/.ssh/authorized_keys

chmod 700 /home/$user_name/.ssh
chmod 600 /home/$user_name/.ssh/authorized_keys
chown -R $user_name:$user_name /home/$user_name/.ssh/
chmod g+s /home/$user_name/.ssh

service sshd restart
sshd -t

echo_info "Instalando essenciais:"
essentials
echo_info "Maquina pronta, pra acessar: "
echo_info "ssh $user_name@ip.da.vm.aqui"
echo_info "Como proximo passo, pode ser que voce queira publicar este conteiner como imagem, criei um script pra auxiliar nisto tambem."

rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
rm /var/lib/dpkg/lock
dpkg --configure -a