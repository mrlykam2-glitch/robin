#!/bin/bash
echo "Starting Tor..."
tor &

echo "Waiting for Tor to be ready (127.0.0.1:9050)..."

# Loop until port 9050 is open, timeout after 90 seconds
timeout 90 bash -c '
until python3 -c "import socket; s=socket.socket(); s.settimeout(2); s.connect((\"127.0.0.1\", 9050)); s.close()" 2>/dev/null; do
  echo "Waiting for Tor socket..."
  sleep 2
done
'

if [ $? -ne 0 ]; then
  echo "ERROR: Tor failed to start or is not listening on port 9050."
  exit 1
fi

echo "Tor is ready."

# Cloud platforms (Render, Cloud Run, Railway, Fly.io, etc.) inject the public
# port via $PORT. Fall back to 8501 for local/Docker usage.
PORT="${PORT:-8501}"

echo "Starting Robin: AI-Powered Dark Web OSINT Tool on port ${PORT}..."
exec streamlit run ui.py \
  --server.port="${PORT}" \
  --server.address=0.0.0.0
