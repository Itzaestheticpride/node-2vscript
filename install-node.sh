#!/bin/bash

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is not installed. Installing sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo is already installed."
fi

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "❌ screen is not installed. Installing screen..."
    sudo apt update
    sudo apt install -y screen
else
    echo "✅ screen is already installed."
fi

# Check if net-tools is installed
if ! command -v ifconfig &> /dev/null; then
    echo "❌ net-tools is not installed. Installing net-tools..."
    sudo apt install -y net-tools
else
    echo "✅ net-tools is already installed."
fi

# Check if lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "❌ lsof is not installed. Installing lsof..."
    sudo apt update
    sudo apt install -y lsof
    sudo apt upgrade -y
else
    echo "✅ lsof is already installed."
fi

while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET NODE-2 INSTALLER Tool-Kit 🚀🚀\e[0m"
    echo "==============================================================="

    # Menu Options
    echo -e "\n\e[1mSelect an action for NODE-2:\e[0m\n"
    echo -e "1) Install Gaia-Node-2 (Non-GPU/VPS)"
    echo -e "2) Start Auto Chat With AI-Agent (Node-2)"
    echo -e "3) Stop Auto Chat (Node-2)"
    echo -e "4) Restart GaiaNet Node-2"
    echo -e "5) Stop GaiaNet Node-2"
    echo -e "6) Check GaiaNet Node-2 Status (Node ID & Device ID)"
    echo -e "7) Uninstall GaiaNet Node-2 (Danger Zone)"
    echo -e "0) Exit Installer"
    echo "==============================================================="

    read -rp "Enter your choice: " choice

    case $choice in
        1)
            echo "Installing Gaia-Node-2..."
            curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base $HOME/node-2
            ;;

        2)
            echo "🔴 Terminating any existing 'gaiabot-node2' screen sessions..."
            screen -ls | awk '/[0-9]+\.gaiabot-node2/ {print $1}' | xargs -r -I{} screen -X -S {} quit

            # Function to check if port 8086 is active
            check_port() {
                if sudo lsof -i :8086 > /dev/null 2>&1; then
                    echo -e "\e[1;32m✅ Port 8086 is active. GaiaNet Node-2 is running.\e[0m"
                    return 0
                else
                    return 1
                fi
            }

            # Check if GaiaNet Node-2 is installed properly
            gaianet_info=$( ~/node-2/bin/gaianet info 2>/dev/null )
            if [[ -z "$gaianet_info" ]]; then
                echo -e "\e[1;31m❌ GaiaNet Node-2 is installed but not configured properly. Please reinstall.\e[0m"
                read -r -p "Press Enter to return to the main menu..."
                continue
            fi

            # Proceed if GaiaNet Node-2 is properly installed
            if [[ "$gaianet_info" == *"Node ID"* || "$gaianet_info" == *"Device ID"* ]]; then
                echo -e "\e[1;32m✅ GaiaNet Node-2 detected. Starting chatbot...\e[0m"

                # Start the chatbot in a detached screen session
                screen -dmS gaiabot-node2 bash -c '
                curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/gaiachat.sh && chmod +x gaiachat.sh;
                if [ -f "gaiachat.sh" ]; then
                    ./gaiachat.sh --base $HOME/node-2
                else
                    echo "❌ Error: Failed to download gaiachat.sh"
                    sleep 10
                    exit 1
                fi'

                sleep 5
                screen -r gaiabot-node2
            fi
            ;;

        3)
            echo "🔴 Stopping Auto Chat on Node-2..."
            screen -ls | awk '/[0-9]+\.gaiabot-node2/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            echo -e "\e[32m✅ Auto Chat for Node-2 stopped.\e[0m"
            ;;

        4)
            echo "Restarting GaiaNet Node-2..."
            sudo netstat -tulnp | grep :8086
            ~/node-2/bin/gaianet stop --base $HOME/node-2
            ~/node-2/bin/gaianet start --base $HOME/node-2
            ~/node-2/bin/gaianet info --base $HOME/node-2
            ;;

        5)
            echo "Stopping GaiaNet Node-2..."
            sudo netstat -tulnp | grep :8086
            ~/node-2/bin/gaianet stop --base $HOME/node-2
            ;;

        6)
            echo "Checking GaiaNet Node-2 ID & Device ID..."
            gaianet_info=$(~/node-2/bin/gaianet info --base $HOME/node-2 2>/dev/null)
            if [[ -n "$gaianet_info" ]]; then
                echo "$gaianet_info"
            else
                echo "❌ GaiaNet Node-2 is not installed or configured properly."
            fi
            ;;

        7)
            echo "⚠️ WARNING: This will completely remove GaiaNet Node-2 from your system!"
            read -rp "Are you sure you want to proceed? (y/n) " confirm
            if [[ "$confirm" == "y" ]]; then
                echo "🗑️ Uninstalling GaiaNet Node-2..."
                curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/uninstall.sh' | bash -s -- --base $HOME/node-2
                source ~/.bashrc
            else
                echo "Uninstallation aborted."
            fi
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -rp "Press Enter to return to the main menu..."
done