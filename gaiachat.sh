#!/bin/bash

# Define API Key storage directory
API_KEY_DIR="$HOME/.gaianet_keys"
API_KEY_FILE="$API_KEY_DIR/apikey_node2"

# Ensure the key directory exists
mkdir -p "$API_KEY_DIR"

# Function to retrieve or request API Key
get_api_key() {
    if [[ -f "$API_KEY_FILE" ]]; then
        api_key=$(cat "$API_KEY_FILE")
        echo "✅ Using saved API key."
    else
        read -rp "Enter your API Key: " api_key
        if [[ -z "$api_key" ]]; then
            echo "❌ No API key provided. Exiting."
            exit 1
        fi
        echo "$api_key" > "$API_KEY_FILE"
        chmod 600 "$API_KEY_FILE"
        echo "✅ API key saved for future use."
    fi
}

# Function to get a random general question
generate_random_question() {
    questions=(
        "What is the capital of France?"
        "Who wrote 'Romeo and Juliet'?"
        "What is the largest planet?"
        "What is the chemical symbol for water?"
        "Who painted the Mona Lisa?"
    )
    echo "${questions[$RANDOM % ${#questions[@]}]}"
}

# Function to send API request
send_request() {
    local message="$1"

    json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
    )

    response=$(curl -s -X POST "https://hyper.gaia.domains/v1/chat/completions" \
        -H "Authorization: Bearer $api_key" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    echo "💬 Question: $message"
    echo "📝 Response: $(echo "$response" | jq -r '.choices[0].message.content' 2>/dev/null)"
}

# Get API key
get_api_key

# Start chatbot loop
while true; do
    random_message=$(generate_random_question)
    send_request "$random_message"
    sleep 5
done
