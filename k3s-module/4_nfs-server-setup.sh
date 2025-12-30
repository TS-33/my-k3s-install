apt update
apt install nfs-server

mkdir -p /share
echo '/share (rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports
systemctl daemon-reload && systemctl restart nfs-server

showmount -e
