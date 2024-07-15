# Stage 1: Build the frontend
FROM node:14 as frontend

WORKDIR /app

# Copy frontend package files
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

# Copy all frontend files
COPY . .

# Build the frontend
RUN npm run build

# Stage 2: Setup backend with CUDA
FROM nvidia/cuda:12.5.0-runtime-ubuntu20.04

# Install Python and other dependencies
RUN apt-get update && apt-get install -y \
    python3.8 \
    python3-pip \
    python3-virtualenv \
    curl \
    gnupg

# Set working directory
WORKDIR /app

# Copy backend files
COPY ./backend ./backend
COPY ./backend/requirements.txt ./backend/requirements.txt

# Setup Python environment
RUN python3 -m virtualenv env

# Activate virtual environment and install requirements
RUN . /app/env/bin/activate && pip install -r ./backend/requirements.txt

# Copy built frontend from the previous stage
COPY --from=frontend /app /app

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

# Expose the ports for frontend and backend
EXPOSE 3000
EXPOSE 5000

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run entrypoint script
CMD ["/entrypoint.sh"]
