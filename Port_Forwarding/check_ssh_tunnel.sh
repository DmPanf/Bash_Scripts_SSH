#!/bin/bash
# 📆 [Created]: 03-09-2023
# 🔋 [Last Modified]: 05-09-2023
# 💾 [File]: /home/${USER}/scr/check_ssh_tunnel.sh
# ⏱  [Crontab]: */3 * * * *  /home/${USER}/scr/check_ssh_tunnel.sh
# 📠 [Description]: This script checks if the SSH tunnel and FastAPI container are running and takes appropriate actions.
# 👤 [Author]: Dmitrii [https://github.com/dmpanf]
# 🎼 [Dependencies]: config.sh, ssh, ps, docker, grep, pkill
# 🛠  [/home/${USER}/scr/config.sh]: ${SSH_PORT}, ${SSH_KEY}

# 🔰 Initialize constants
DOCKER_NAME="000-fastapi_app"
REMOTE_PORT="8001"
LOCAL_PORT="8001"
REMOTE_USER_SERVER="${USER}@api-serv.ru"

# 🔘 Check if Config File is available
if [ -f "/home/${USER}/scr/config.sh" ]; then
    source /home/${USER}/scr/config.sh
else
    echo "⛔️ Config file not found. Exiting."
    exit 1
fi

# ⚙️  Check if constants are set
check_constants() {
    if [[ -z "$REMOTE_PORT" || -z "$LOCAL_PORT" || -z "$REMOTE_USER_SERVER" ]]; then
        echo "🔰 Some constants are not set. Please provide them:"
        read -p "💠 Docker name [${DOCKER_NAME}]: " DOCKER_NAME
        read -p "1️⃣  Remote port [${REMOTE_PORT}]: " REMOTE_PORT
        read -p "2️⃣  Local port [${LOCAL_PORT}]: " LOCAL_PORT
        read -p "📡 Remote user and server (user@server) [${REMOTE_USER_SERVER}]: " REMOTE_USER_SERVER
    fi
}

# ⚙️  Function to check and set ufw rule on the remote server
#    This might not work well in an automated script without human interaction.
# If the sudo commands are being run on a remote server, you can configure SSH to allocate a pseudo-terminal for that session with -t flag
check_and_set_ufw_rule() {
    isUfwRule=$(ssh -t -p ${SSH_PORT} ${REMOTE_USER_SERVER} -i /home/${USER}/.ssh/${SSH_KEY} 'sudo ufw status | grep ${REMOTE_PORT}/tcp')
    if [[ ! $isUfwRule ]]; then
        ssh -t -p ${SSH_PORT} ${REMOTE_USER_SERVER} -i /home/${USER}/.ssh/${SSH_KEY} 'sudo ufw allow ${REMOTE_PORT}/tcp'
        echo "🔑 UFW rule is set!"
    fi
}

# ⚙️  Function to check and set crontab entry
check_and_set_crontab() {
    isCronJob=$(crontab -l | grep "/home/${USER}/scr/check_ssh_tunnel.sh")
    if [[ ! $isCronJob ]]; then
        (crontab -l ; echo "*/3 * * * * /home/${USER}/scr/check_ssh_tunnel.sh") | crontab -
        echo "⏱  Crontab is set!"
    fi
}

# ⚙️  Call the above functions if the script is running in a user session
if [[ -n "$TERM" && -n "$SHELL" ]]; then
    # The script is running in a user session
    check_and_set_ufw_rule  # Enter the password for Remote Server
    check_and_set_crontab
    check_constants
else
    # The script is running in a cron job
    # Do nothing or do something else
    exit 1
fi


# 🔘 Check if the SSH daemon is running
isSSH=$(ps -ef | grep "[s]sh.*${REMOTE_PORT}:localhost:${LOCAL_PORT}")

# 🔘 Check if the FastAPI Docker container is running
isFastAPI=$(docker ps --filter "ancestor=${DOCKER_NAME}" --filter "status=running" | grep "0.0.0.0:${LOCAL_PORT}->${LOCAL_PORT}/tcp")


# 🔘 If FastAPI is running but SSH tunnel is not, establish the SSH tunnel
if [[ $isFastAPI && ! $isSSH ]]; then
    ssh -f -N -R ${REMOTE_PORT}:localhost:${LOCAL_PORT} -p ${SSH_PORT} ${REMOTE_USER_SERVER} -i /home/${USER}/.ssh/${SSH_KEY}
    echo "✅ SSH tunnel established ♻️ " | wall
# If SSH tunnel is running but FastAPI is not, kill the SSH session
elif [[ $isSSH && ! $isFastAPI ]]; then
    pkill -f "ssh -f -N -R ${REMOTE_PORT}:localhost:${LOCAL_PORT} -p ${SSH_PORT} ${REMOTE_USER_SERVER} -i /home/${USER}/.ssh/${SSH_KEY}"
    echo "❌ SSH tunnel terminated ‼️ " | wall
fi
