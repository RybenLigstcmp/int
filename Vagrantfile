# -*- mode: ruby -*-
# vi: set ft=ruby :

VIRT_COUNT = 3
BASE_NETWORK = "10.10.10."
BASE_IP = 140
SSH_USER = "vagrant"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine38"
  config.ssh.insert_key = false

  vm_ips = (1..VIRT_COUNT).map { |i| "#{BASE_NETWORK}#{BASE_IP + i}" }

  (1..VIRT_COUNT).each do |i|
    current_ip = "#{BASE_NETWORK}#{BASE_IP + i}"
    neighbors = vm_ips - [current_ip]

    config.vm.define "sftp#{i}" do |sftp|
      sftp.vm.hostname = "sftp#{i}"
      sftp.vm.network "private_network", ip: current_ip
      
      # SSH Key copy to machines
      sftp.vm.provision "file", source: "keys/sftp_key", destination: "/tmp/sftp_key"
      sftp.vm.provision "file", source: "keys/sftp_key.pub", destination: "/tmp/sftp_key.pub"

      # Main
      sftp.vm.provision "shell", inline: <<-SHELL
        # Setup SSH keys
        mkdir -p /home/#{SSH_USER}/.ssh
        mv /tmp/sftp_key* /home/#{SSH_USER}/.ssh/
        chmod 700 /home/#{SSH_USER}/.ssh
        chmod 600 /home/#{SSH_USER}/.ssh/sftp_key
        chmod 644 /home/#{SSH_USER}/.ssh/sftp_key.pub
        cat /home/#{SSH_USER}/.ssh/sftp_key.pub >> /home/#{SSH_USER}/.ssh/authorized_keys
        chown -R #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/.ssh

        mkdir -p /home/#{SSH_USER}/uploads
        chown #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/uploads

        # Installing 
        apk update
        apk add openssh-server sudo shadow fail2ban wget xz --repository=http://dl-cdn.alpinelinux.org/alpine/v3.8/community

        # SSH
        sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
        echo "Protocol 2" >> /etc/ssh/sshd_config

        # Conf fail2ban
        mkdir -p /var/run/fail2ban
        cat << EOF > /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
logpath = /var/log/messages
EOF
        rc-service sshd restart
        rc-service fail2ban start
        rc-update add fail2ban

        # Install rkhunter and conf
        apk add --no-cache perl
        wget https://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz
        tar xvf rkhunter-1.4.6.tar.gz
        cd rkhunter-1.4.6
        ./installer.sh --layout default --install
        chmod 755 /usr/local/bin/rkhunter
        chmod +x /usr/local/bin/rkhunter
        rkhunter --update
        rkhunter --propupd

        # Neighbors config
        echo "#{neighbors.join(' ')}" > /home/#{SSH_USER}/neighbors.conf
        chown #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/neighbors.conf
        chmod 644 /home/#{SSH_USER}/neighbors.conf
      SHELL

      # scheduler
      sftp.vm.provision "file", source: "scheduler.sh", destination: "/home/#{SSH_USER}/scheduler.sh"
      sftp.vm.provision "shell", inline: <<-SHELL
        chmod +x /home/#{SSH_USER}/scheduler.sh
        chown #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/scheduler.sh
        echo "*/5 * * * * /home/#{SSH_USER}/scheduler.sh" | crontab -u #{SSH_USER} -
      SHELL
    end
  end
end
