#!/bin/bash

# Kill any existing processes holding ports 3000, 8000, or 8001
echo "Cleaning up existing processes on ports 3000, 8000, 8001..."
kill -9 $(lsof -t -i :3000) 2>/dev/null || true
kill -9 $(lsof -t -i :8000) 2>/dev/null || true
kill -9 $(lsof -t -i :8001) 2>/dev/null || true

# Function to cleanly stop all background processes when the script is stopped
cleanup() {
    echo -e "\nStopping all services..."
    kill $(jobs -p) 2>/dev/null || true
    exit 0
}
# Catch Ctrl+C and script termination
trap cleanup SIGINT SIGTERM

# 1. Start Backend API (Port 8000)
echo "Starting Backend API (Port 8000)..."
source backend/venv/bin/activate
uvicorn src.main:app --reload --port 8000 &
BACKEND_PID=$!

# 2. Start AI Service (Port 8001)
echo "Starting AI Service (Port 8001)..."
uvicorn ai.main:app --reload --port 8001 &
AI_PID=$!

# 3. Start Frontend Web (Port 3000)
echo "Starting Frontend Web (Port 3000)..."
cd ui
flutter run -d chrome --web-port 3000 &
FRONTEND_PID=$!

echo "=================================================="
echo "All services are starting up!"
echo "- Backend: http://localhost:8000"
echo "- AI Service: http://localhost:8001"
echo "- Frontend: http://localhost:3000"
echo "Press Ctrl+C to stop all services."
echo "=================================================="

# Wait for all background processes
wait $BACKEND_PID $AI_PID $FRONTEND_PID
