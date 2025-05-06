# -*- mode: ruby -*-
# vi: set ft=ruby :

VIRT_COUNT = 3
BASE_NETWORK = "10.10.10."
BASE_IP = 140  # Start IP
SSH_USER = "vagrant"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine38"
  config.ssh.insert_key = false

  # IP prepairimg
  vm_ips = (1..VIRT_COUNT).map { |i| "#{BASE_NETWORK}#{BASE_IP + i}" }

  (1..VIRT_COUNT).each do |i|
    current_ip = "#{BASE_NETWORK}#{BASE_IP + i}"
    neighbors = vm_ips - [current_ip]

    config.vm.define "sftp#{i}" do |sftp|
      sftp.vm.hostname = "sftp#{i}"
      sftp.vm.network "private_network", ip: current_ip
      
      # SSH ke
      sftp.vm.provision "file", source: "keys/", destination: "/home/#{SSH_USER}/.ssh/"
      
      # Main script
      sftp.vm.provision "shell", inline: <<-SHELL
        # Create dir
        mkdir -p /home/#{SSH_USER}/uploads
        chown -R #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}

        # Install
        apk update
        apk add openssh-server rkhunter fail2ban sudo shadow
        apk add --no-cache openssh-keygen

        # SSH conf
        sudo -u #{SSH_USER} mkdir -p /home/#{SSH_USER}/.ssh
        cat /home/#{SSH_USER}/.ssh/sftp_key.pub >> /home/#{SSH_USER}/.ssh/authorized_keys
        chmod 700 /home/#{SSH_USER}/.ssh
        chmod 600 /home/#{SSH_USER}/.ssh/authorized_keys

        # SSH server conf
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
        echo "Protocol 2" >> /etc/ssh/sshd_config

        # Restart SSH
        rc-service sshd restart

        # join susidy
        echo "#{neighbors.join(' ')}" > /home/#{SSH_USER}/neighbors.conf

        # Security setup
        rkhunter --update
        rkhunter --propupd
        rkhunter --check --sk

        # Setup fail2ban
        cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        rc-service fail2ban start
        rc-update add fail2ban

        # Scheduler
        echo "*/5 * * * * /home/#{SSH_USER}/scheduler.sh" | crontab -u #{SSH_USER} -
      SHELL

      # Copy upload script
      sftp.vm.provision "file", source: "scheduler.sh", destination: "/home/#{SSH_USER}/scheduler.sh"
      
      # Set permissions
      sftp.vm.provision "shell", inline: <<-SHELL
        chmod +x /home/#{SSH_USER}/scheduler.sh
        chown #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/scheduler.sh
      SHELL
    end
  end
end