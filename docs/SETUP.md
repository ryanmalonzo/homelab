# Setup

## Install sudo

```bash
su -
apt update
apt install sudo -y
```

## Add `ren` to sudo group

```bash
usermod -aG sudo ren
```

## Set timezone

```bash
sudo timedatectl set-timezone Europe/Paris
```

## Install vim

```bash
sudo apt install vim -y
```

## Configure sshd

```bash
sudo vim /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Enable contrib repositories (add `contrib` after `main` to each line)

```bash
sudo vim /etc/apt/sources.list
sudo apt update
```

## Import ZFS pool (https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html)

```bash
sudo apt install dpkg-dev linux-headers-generic linux-image-generic -y
sudo apt install zfs-dkms zfsutils-linux -y
sudo modprobe zfs
sudo zpool import -f tank
sudo chown -R ren:ren /tank
```

## Persist ZFS pool on boot

```bash
sudo zpool set cachefile=/etc/zfs/zpool.cache tank
sudo systemctl enable zfs-import-cache.service zfs-mount.service zfs.target
sudo update-initramfs -u
sudo reboot
zpool status
```

## Install K3s

```bash
sudo apt install curl -y
curl -sfL https://get.k3s.io | sh -
```

## Use K3s without sudo

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >>~/.bashrc
source ~/.bashrc
kubectl get nodes
```

## Use `kubectl` from local machine

```bash
cat ~/.kube/config
# Manually copy over to local ~/.kube/config
# And replace 127.0.0.1 with the correct local IP
kubectl get nodes
```

Next steps: [ARGOCD.md](https://github.com/ryanmalonzo/homelab/blob/main/docs/ARGOCD.md)
