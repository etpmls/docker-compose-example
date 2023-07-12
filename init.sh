#!/bin/bash
ADMIN_USERNAME=YOUR_USERNAME # Your administrator username
ADMIN_PASSWORD=YOUR_PASSWORD # Your administrator password
SSH_PORT=YOUR_SSH_PORT # Your SSH port

# Create an admin user
create_admin() {
    local username=$1
    local password=$2
    
    # Create user
    useradd -m "$username" -g sudo -s /bin/bash -d "/home/$username"
    # Set password
    echo "$username:$password" | chpasswd
}

# Create SSH key
create_ssh_key() {
    local username=$1

    if [ "$username" == "root" ]; then
        local ssh_dir="/root/.ssh"
    else
        local ssh_dir="/home/$username/.ssh"
    fi
    if [ ! -d "$ssh_dir" ]; then
        mkdir -p "$ssh_dir"
    fi

    # Create root user SSH key
    ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa" -N ""
    # Set SSH key permissions
    chown $username "$ssh_dir/id_rsa"
    chmod 600 "$ssh_dir/id_rsa"
    chmod 644 "$ssh_dir/id_rsa.pub"
    # Add the public key in the authorized_key file
    cat "$ssh_dir/id_rsa.pub" >> "$ssh_dir/authorized_keys"
}

# Update SSH config
update_ssh_config() {
    local port=$1
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    # Check that the Port 22 line is commented
    if grep -qE '^#Port 22' /etc/ssh/sshd_config; then
        # Uncomment and modify the port
        sed -i "s/^#Port 22/Port $port/" /etc/ssh/sshd_config
    else
        # Modify the port directly
        sed -i "s/^Port.*/Port $port/" /etc/ssh/sshd_config
    fi
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Install docker
install_docker() {
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

rollback() {
    echo "An error occurred. Rolling back changes..."
    
    if [ -d "/root/.ssh" ] && [ -n "$(ls -A /root/.ssh)" ]; then
        rm -r /root/.ssh/*
    fi
    if [ -d "/home/$ADMIN_USERNAME/.ssh" ] && [ -n "$(ls -A /home/$ADMIN_USERNAME/.ssh)" ]; then
        rm -r /home/$ADMIN_USERNAME/.ssh/*
    fi
    if id "$ADMIN_USERNAME" >/dev/null 2>&1; then
        echo "User $ADMIN_USERNAME exists. Deleting user..."
        # Delete admin user
        userdel -r "$ADMIN_USERNAME"
        echo "User $ADMIN_USERNAME deleted."
    fi
    mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config

    echo "Changes rolled back."
}

clean() {
    rm /etc/ssh/sshd_config.bak
}

set -e
create_admin "$ADMIN_USERNAME" "$ADMIN_PASSWORD"
create_ssh_key "root"
create_ssh_key "$ADMIN_USERNAME"
update_ssh_config $SSH_PORT
install_docker
# Check the exit status of the last command
if [ $? -ne 0 ]; then
    rollback
else
    clean
    echo "Script running successfully."
fi
