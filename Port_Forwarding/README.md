## SSH Tunnel & FastAPI Health Check

### Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Installation](#installation)
  - [FastAPI Deployment](#fastapi-deployment)
  - [SSH Tunnel Configuration](#ssh-tunnel-configuration)
  - [UFW Rules on Remote Server](#ufw-rules-on-remote-server)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Usage](#usage)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

### Overview

This script (`check_ssh_tunnel.sh`) is designed to automatically manage an SSH tunnel and a FastAPI container. The script checks the status of both the SSH tunnel and the FastAPI container running in Docker. Depending on their statuses, it takes appropriate actions to either establish or terminate the SSH tunnel.

### System Architecture

Here is a simplified ASCII diagram illustrating the interaction between the local machine running a FastAPI instance and a remote server, connected through an SSH tunnel.

```
                     +---------------------+
                     |    Local Machine    |  
                     |     (FastAPI)       |
                     +----------+----------+ 
                            || SSH [-R]
                            || Tunnel 
                            \/ 8001:8001
                     +---------------------+ 
                     |    Remote Server    | 
                     |    (api-serv.ru)    |
                     +---------------------+
```

#### Key Components

1. **Local Machine (FastAPI)**: This is where the FastAPI application runs inside a Docker container. It exposes port `8001` to interact with the SSH tunnel.

2. **SSH Tunnel**: An encrypted tunnel established between the local machine and the remote server. This is set up to forward traffic from a specified port on the remote server to a specified port on the local machine (FastAPI).

3. **Remote Server (api-serv.ru)**: This is the external server that listens on a specified port (`8001`). It receives incoming traffic and forwards it through the SSH tunnel to the FastAPI instance on the local machine.
   
### Installation

#### FastAPI Deployment

1. **Docker Setup**: Your FastAPI application should be containerized using Docker. Make sure the Docker daemon is running.
  
   ```
   docker-compose up -d
   ```
   
2. **Port Exposure**: Ensure that the FastAPI application inside the Docker container exposes the port you intend to tunnel (e.g., `8001`).

#### SSH Tunnel Configuration

1. **SSH Key Pair**: If you haven't already, generate an SSH key pair for secure, password-less authentication to the remote server.
   
   ```
   ssh-keygen -t ed25519
   ```

2. **SSH Connection**: Use the SSH `-R` option to set up the reverse tunnel. Your script automates this.

   ```
   ssh -f -N -R 8001:localhost:8001 -p xxxxx username@api-serv.ru -i ~/.ssh/id_ed25519
   ```
   
3. **Automate with Cron**: Your `check_ssh_tunnel.sh` script is set up to automatically establish the tunnel if it's not active. Add this script to your crontab to run it at regular intervals.
   
   ```
   crontab -e
   ```

#### UFW Rules on Remote Server

1. **Install UFW**: If not already installed, you can install UFW on your Ubuntu server with:
   
   ```
   sudo apt-get install ufw
   ```
   
2. **Allow Port**: Open up the port (`8001` in this case) on UFW.

   ```
   sudo ufw allow 8001/tcp
   ```

3. **Enable UFW**: Finally, enable UFW with:

   ```
   sudo ufw enable
   ```

By following these steps, you ensure that the FastAPI application, the SSH tunnel, and the remote server are correctly configured to communicate with each other securely and reliably.

#### Prerequisites

The script has the following dependencies:

- SSH client
- Docker
- `ps`, `grep`, and `pkill` command-line utilities

Please make sure these dependencies are installed on your system.

#### Setup

1. Clone the repository:

    ```bash
    git clone https://github.com/dmpanf/Bash_Scripts_SSH.git
    ```

2. Navigate to the directory:

    ```bash
    cd Bash_Scripts_SSH
    ```

3. Make the script executable:

    ```bash
    chmod +x check_ssh_tunnel.sh
    ```

4. Copy or create the `config.sh` file in the same directory as `check_ssh_tunnel.sh`. Example `config.sh` content:

    ```bash
    SSH_PORT=xxxxx
    SSH_KEY="id_ed25519.XXX"
    ```

5. Update the `.gitignore` file to ignore the `config.sh`:

    ```bash
    echo "config.sh" >> .gitignore
    ```

### Usage

To run the script, execute:

```bash
./check_ssh_tunnel.sh
```

To set up a crontab to run this script every 3 minutes, execute:

```bash
(crontab -l ; echo "*/3 * * * * /home/${USER}/scr/check_ssh_tunnel.sh") | crontab -
```

### Customization

All customization can be done via the `config.sh` file or directly in the `check_ssh_tunnel.sh` script. You can set the following:

- Docker container name (`DOCKER_NAME`)
- Remote and Local port numbers (`REMOTE_PORT` and `LOCAL_PORT`)
- Remote User and Server (`REMOTE_USER_SERVER`)
- SSH Port (`SSH_PORT`)
- SSH Key (`SSH_KEY`)

### Contributing

Contributions, issues, and feature requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Contact

- Author: Dmitrii 
- GitHub: [dmpanf](https://github.com/dmpanf)

---
