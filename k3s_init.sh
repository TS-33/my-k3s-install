## Only suit for Ubuntu.

which k3s-uninstall.sh && k3s-uninstall.sh

#配置IPVS
apt-get update && apt-get install -y ipset ipvsadm
set -e
cat <<EOF | sudo tee /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF
sudo systemctl restart systemd-modules-load

#安装k3s
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC=" \
  --disable traefik \
  --disable servicelb \
  --kube-proxy-arg proxy-mode=ipvs \
  --kube-proxy-arg ipvs-scheduler=lc \
  --kube-proxy-arg=ipvs-strict-arp=true" sh -

#安装最新的nerdctl
NERDCTL_VERSION=$(curl -s https://api.github.com/repos/containerd/nerdctl/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
wget https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz
tar -xzf  nerdctl*tar.gz -C /bin

#安装cni
VERSION=$(curl -sI https://github.com/containernetworking/plugins/releases/latest | grep -i "location:" | awk -F "/" '{print $NF}' | tr -d '\r')
wget "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-amd64-${VERSION}.tgz"
mkdir /opt/cni/bin -p
tar xzf cni-plugins-linux-amd64-${VERSION}.tgz -C /opt/cni/bin

#配置命令补全
cat > /etc/profile.d/nerdctl.sh << \EOF
export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
export CONTAINERD_NAMESPACE=k8s.io
alias docker=nerdctl
. <(kubectl completion bash)
. <(nerdctl completion bash)
EOF
. /etc/profile.d/nerdctl.sh

mkdir -p ~/.kube
if [ ! -f ~/.kube/config ]; then
    ln -sf /etc/rancher/k3s/k3s.yaml ~/.kube/config
fi

# 生成 worker_join.sh
cat > worker_join.sh << EOF
# 卸载原先的 k3s agent
which k3s-agent-uninstall.sh && k3s-agent-uninstall.sh

set -e
# 配置 IPVS
apt-get update && apt-get install -y ipset ipvsadm
cat << \INNEREOF | sudo tee /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
INNEREOF

sudo systemctl restart systemd-modules-load

# 安装 k3s
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
INSTALL_K3S_MIRROR=cn \
K3S_URL=https://$(hostname -I | awk '{print $1}'):6443 \
K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token) \
INSTALL_K3S_EXEC="--kube-proxy-arg=proxy-mode=ipvs --kube-proxy-arg=ipvs-strict-arp=true" sh -
set +e
EOF
echo 已生成worker_join.sh脚本,请在worker节点上执行
set +e

