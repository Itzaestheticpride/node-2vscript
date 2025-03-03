#!/bin/bash

NODE_DIR="$HOME/node-2"
API_KEY_DIR="$NODE_DIR"
mkdir -p "$API_KEY_DIR"

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected."
        return 0  
    else
        echo "❌ NVIDIA GPU Not Found."
        return 1  
    fi
}

# Function to check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1  
    else
        echo "✅ This is a Desktop."
        return 2  
    fi
}

# Set API URL based on system type and CUDA presence
set_api_url() {
    check_system_type
    system_type=$?

    check_cuda
    cuda_present=$?

    if [ "$system_type" -eq 0 ]; then
        API_URL="https://hyper.gaia.domains/v1/chat/completions"
        API_NAME="Hyper"
    elif [ "$system_type" -eq 1 ]; then
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://soneium.gaia.domains/v1/chat/completions"
            API_NAME="Soneium"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    elif [ "$system_type" -eq 2 ]; then
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gadao.gaia.domains/v1/chat/completions"
            API_NAME="Gadao"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    fi

    echo "🔗 Using API: ($API_NAME)"
}

set_api_url

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing..."
    sudo apt update && sudo apt install jq -y
fi

# Load or create API Key for Node-2
if [ -f "$API_KEY_DIR/api_key" ]; then
    api_key=$(cat "$API_KEY_DIR/api_key")
    echo "✅ Loaded API key for Node-2."
else
    echo -n "Enter your API Key for Node-2: "
    read -r api_key
    echo "$api_key" > "$API_KEY_DIR/api_key"
fi

# Start Chatbot for Node-2
echo "🚀 Starting Auto Chat for Node-2..."
screen -dmS gaiabot-node2 bash -c "
cd $NODE_DIR &&
./gaiachat.sh --base $NODE_DIR --port 8086
"

echo "✅ Gaia Auto Chat started for Node-2 on port 8086."
