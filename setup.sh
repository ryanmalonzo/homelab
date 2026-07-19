# Install sudo
su -
apt update
apt install sudo -y

# Add `ren` to sudo group
usermod -aG sudo ren

# Set timezone
sudo timedatectl set-timezone Europe/Paris

# Install vim
sudo apt install vim -y

# Configure sshd
sudo vim /etc/ssh/sshd_config
sudo systemctl restart sshd

# Enable contrib repositories (add `contrib` after `main` to each line)
sudo vim /etc/apt/sources.list
sudo apt update

# Import ZFS pool (https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html)
sudo apt install dpkg-dev linux-headers-generic linux-image-generic -y
sudo apt install zfs-dkms zfsutils-linux -y
sudo modprobe zfs
sudo zpool import -f tank
sudo chown -R ren:ren /tank

# Persist ZFS pool on boot
sudo zpool set cachefile=/etc/zfs/zpool.cache tank
sudo systemctl enable zfs-import-cache.service zfs-mount.service zfs.target
sudo update-initramfs -u
sudo reboot
zpool status

# Install K3s
sudo apt install curl -y
curl -sfL https://get.k3s.io | sh -

# Use K3s without sudo
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >>~/.bashrc
source ~/.bashrc
kubectl get nodes
