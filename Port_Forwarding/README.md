### Table of Contents

- [Overview](#overview)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Usage](#usage)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

### Overview

This script (`check_ssh_tunnel.sh`) is designed to automatically manage an SSH tunnel and a FastAPI container. The script checks the status of both the SSH tunnel and the FastAPI container running in Docker. Depending on their statuses, it takes appropriate actions to either establish or terminate the SSH tunnel.

### Installation

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
