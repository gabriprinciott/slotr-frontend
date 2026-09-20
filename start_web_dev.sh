#!/bin/bash
echo "========================================================"
echo "Starting Flutter Web Server..."
echo "The application will be accessible from:"
echo " - This computer: http://localhost:8080"
echo " - Other devices: http://<YOUR_IP_ADDRESS>:8080"
echo "========================================================"
echo ""

flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release