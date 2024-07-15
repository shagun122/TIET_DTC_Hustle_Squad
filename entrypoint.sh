#!/bin/sh

# Start the frontend
cd /app
npm start &

# Start the backend
cd /app/backend
. /app/env/bin/activate
flask run --host=0.0.0.0 --port=5000
