#!/bin/bash

# Step 1: Set up the backend (Django + Azure CLI)
echo "Setting up Django backend..."
mkdir -p azure-web-terminal/backend
cd azure-web-terminal/backend || exit
django-admin startproject azure_terminal
cd azure_terminal || exit
pip install django djangorestframework azure-identity azure-mgmt-resource azure-cli

# Create views.py
cat <<EOL > azure_terminal/views.py
from django.http import JsonResponse
import subprocess
import json

def execute_command(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        command = data.get('command', '')

        if not command.startswith('az'):
            return JsonResponse({'output': 'Invalid command'}, status=400)

        try:
            result = subprocess.run(command.split(), capture_output=True, text=True)
            return JsonResponse({'output': result.stdout or result.stderr})
        except Exception as e:
            return JsonResponse({'output': str(e)}, status=500)
EOL

# Create urls.py
cat <<EOL > azure_terminal/urls.py
from django.urls import path
from .views import execute_command

urlpatterns = [
    path('api/execute', execute_command)
]
EOL

# Step 2: Set up the frontend (React + XTerm.js)
echo "Setting up React frontend..."
cd ../../
npx create-react-app frontend
cd frontend || exit
npm install xterm axios

# Create Terminal.jsx
mkdir -p src/components
cat <<EOL > src/components/Terminal.jsx
import React, { useEffect, useRef } from 'react';
import { Terminal } from 'xterm';
import 'xterm/css/xterm.css';
import axios from 'axios';

const AzureTerminal = () => {
    const terminalRef = useRef(null);
    const term = useRef(null);

    useEffect(() => {
        term.current = new Terminal();
        term.current.open(terminalRef.current);
        term.current.writeln('Welcome to Azure Web Terminal');

        term.current.onData((input) => {
            axios.post('/api/execute', { command: input })
                .then((res) => {
                    term.current.write(res.data.output + '\r\n');
                })
                .catch(() => term.current.write('Error: Failed to execute command\r\n'));
        });
    }, []);

    return <div ref={terminalRef} style={{ height: '100vh', width: '100%' }}></div>;
};

export default AzureTerminal;
EOL

# Create App.js
cat <<EOL > src/App.js
import AzureTerminal from './components/Terminal';

function App() {
    return (
        <div className="App">
            <AzureTerminal />
        </div>
    );
}

export default App;
EOL

# Step 3: Create Docker deployment (docker-compose.yml)
echo "Setting up Docker deployment..."
cd ../
cat <<EOL > docker-compose.yml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    command: python manage.py runserver 0.0.0.0:8000
EOL

# Step 4: Instructions for running the project
echo "To run the project, use the following commands:"
echo "1. Run Backend: cd azure-web-terminal/backend && python manage.py runserver"
echo "2. Run Frontend: cd azure-web-terminal/frontend && npm start"
echo "3. Access the terminal at: http://localhost:3000"
