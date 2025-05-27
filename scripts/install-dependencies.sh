#!/bin/bash

# Script to install dependencies for set-claude-secrets.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking and installing dependencies...${NC}"

# Check if gh CLI is installed
if command -v gh &> /dev/null; then
    echo -e "${GREEN}✓ GitHub CLI (gh) is already installed${NC}"
else
    echo -e "${YELLOW}Installing GitHub CLI...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            echo "Detected Debian/Ubuntu system"
            echo "Running: sudo apt update && sudo apt install -y gh"
            sudo apt update && sudo apt install -y gh
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            echo "Detected RHEL/CentOS/Fedora system"
            echo "Running: sudo dnf install -y gh"
            sudo dnf install -y gh
        else
            echo -e "${RED}Unsupported Linux distribution${NC}"
            echo "Please install GitHub CLI manually from: https://cli.github.com/manual/installation"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "Running: brew install gh"
            brew install gh
        else
            echo -e "${RED}Homebrew not found${NC}"
            echo "Please install Homebrew first: https://brew.sh/"
            exit 1
        fi
    else
        echo -e "${RED}Unsupported operating system${NC}"
        echo "Please install GitHub CLI manually from: https://cli.github.com/"
        exit 1
    fi
fi

# Check if jq is installed
if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ jq is already installed${NC}"
else
    echo -e "${YELLOW}Installing jq...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if [ -f /etc/debian_version ]; then
            # Debian/Ubuntu
            echo "Detected Debian/Ubuntu system"
            echo "Running: sudo apt update && sudo apt install -y jq"
            sudo apt update && sudo apt install -y jq
        elif [ -f /etc/redhat-release ]; then
            # RHEL/CentOS/Fedora
            echo "Detected RHEL/CentOS/Fedora system"
            echo "Running: sudo dnf install -y jq"
            sudo dnf install -y jq
        else
            echo -e "${RED}Unsupported Linux distribution${NC}"
            echo "Please install jq manually"
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "Running: brew install jq"
            brew install jq
        else
            echo -e "${RED}Homebrew not found${NC}"
            echo "Please install Homebrew first: https://brew.sh/"
            exit 1
        fi
    else
        echo -e "${RED}Unsupported operating system${NC}"
        echo "Please install jq manually"
        exit 1
    fi
fi

echo -e "${GREEN}All dependencies are installed!${NC}"

# Check if gh is authenticated
if gh auth status &> /dev/null; then
    echo -e "${GREEN}✓ GitHub CLI is authenticated${NC}"
else
    echo -e "${YELLOW}GitHub CLI is not authenticated${NC}"
    echo "Please run: gh auth login"
fi