#!/bin/bash

# Function to install MongoDB
install_mongodb() {
    echo "Step 1: Importing MongoDB public GPG key..."
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
    if [ $? -ne 0 ]; then
        echo "Error: Failed to import MongoDB GPG key."
        exit 1
    fi

    echo "Step 2: Creating the MongoDB repository list file..."
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add MongoDB repository."
        exit 1
    fi

    echo "Step 3: Updating package database..."
    sudo apt-get update
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update package list."
        exit 1
    fi

    echo "Step 4: Installing MongoDB..."
    sudo apt-get install -y mongodb-org
    if [ $? -ne 0 ]; then
        echo "Error: MongoDB installation failed."
        exit 1
    fi
}

# Function to verify MongoDB installation
verify_mongodb() {
    echo "Verifying MongoDB installation..."

    # Check if MongoDB is installed
    if ! command -v mongod &> /dev/null; then
        echo "Error: MongoDB is not installed or not in the PATH."
        exit 1
    else
        echo "MongoDB is installed."
    fi

    # Check the MongoDB version
    mongo_version=$(mongod --version | grep -oP 'db version v\K[^\s]+')
    if [ -z "$mongo_version" ]; then
        echo "Error: Could not determine MongoDB version."
        exit 1
    else
        echo "MongoDB version $mongo_version is installed."
    fi

    # Check if MongoDB service is running
    sudo systemctl start mongod
    sudo systemctl enable mongod

    if systemctl is-active --quiet mongod; then
        echo "MongoDB service is running."
    else
        echo "Error: MongoDB service is not running."
        exit 1
    fi
}

# Main script execution
echo "Starting MongoDB installation..."
install_mongodb
verify_mongodb

echo "MongoDB installation and verification completed successfully."
