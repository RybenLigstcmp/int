# SFTP Server Infrastructure with Monitoring

This project sets up a secure SFTP infrastructure with three virtual machines, each running an SFTP server with key-based authentication and security monitoring. The system includes automated log generation and a web-based monitoring interface.

## Infrastructure Components

1. Three Alpine Linux virtual machines running SFTP servers
2. Key-based authentication for all servers
3. Security monitoring with rkhunter and fail2ban
4. Automated log generation every 5 minutes
5. Web-based monitoring interface (Flask application)

## Prerequisites

- Vagrant
- VirtualBox or another Vagrant provider
- Docker (for running the monitoring application)

## Deployment Instructions

### 1. SFTP Server Setup

1. Clone this repository
2. Generate SSH keys for SFTP access:
   ```bash
   mkdir -p keys
   ssh-keygen -t rsa -b 4096 -f keys/sftp_key -N ""
   ```
3. Start the virtual machines:
   ```bash
   vagrant up
   ```

### 2. Monitoring Application Setup

1. Build and run the Docker container:
   ```bash
   cd flask_app
   docker build -t sftp-monitor .
   docker run -d -p 8888:8888 -v $(pwd)/../logs:/logs sftp-monitor
   ```

## Security Features

- Key-based authentication only (password authentication disabled)
- fail2ban for brute force protection
- rkhunter for rootkit detection
- Regular security updates
- Restricted SSH access

## Monitoring

The monitoring application provides:
- Real-time statistics of SFTP server activity
- Number of records created by each server
- Last seen timestamp for each server
- IP address tracking

Access the monitoring interface at: http://localhost:8888

## Log Generation

Each SFTP server:
- Creates log files every 5 minutes
- Distributes logs to neighboring servers
- Includes timestamp and server identification
- Stores logs in the `/home/vagrant/uploads` directory

## Maintenance

1. Regular security updates:
   ```bash
   vagrant ssh sftp1
   sudo apk update && sudo apk upgrade
   ```

2. Check rkhunter status:
   ```bash
   sudo rkhunter --check
   ```

3. View fail2ban status:
   ```bash
   sudo fail2ban-client status
   ```
