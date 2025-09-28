#!/bin/bash

# Made using Claude sonnet 4:
# https://claude.ai/share/04f7be83-a18a-4c8a-a4a9-25be43da27b1

# Check if app.R exists
if [ ! -f "/srv/app/app.R" ]; then
    echo "ERROR: app.R not found"
    exit 1
fi

# Start Shiny app in background
echo "Starting Shiny server with app.R..."
R -e "shiny::runApp('app.R', port=8080)" &
SHINY_PID=$!

# Wait for Shiny to start
echo "Waiting for Shiny server to start..."
sleep 5
# Check if tunnel token is provided
if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
    echo "Starting Cloudflare tunnel with token..."
    cloudflared tunnel --no-autoupdate --url http://localhost:8080 run --token $CLOUDFLARE_TUNNEL_TOKEN &
    TUNNEL_PID=$!
    echo "Cloudflare tunnel started. Your app will be accessible via your Cloudflare tunnel URL."
else
    echo "No Cloudflare tunnel token provided. Starting quick tunnel..."
    cloudflared tunnel --url http://localhost:3838 &
    TUNNEL_PID=$!
    echo "Quick tunnel started. Check logs above for the temporary URL."
fi

# Function to handle shutdown
cleanup() {
    echo "Shutting down..."
    kill $SHINY_PID 2>/dev/null
    kill $TUNNEL_PID 2>/dev/null
    exit 0
}

# Trap SIGTERM and SIGINT
trap cleanup SIGTERM SIGINT

# Wait for processes
wait