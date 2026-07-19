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
