#!/bin/bash

# Script to set GitHub repository secrets from Claude credentials
# Requires GitHub CLI (gh) to be installed and authenticated

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if credentials file exists
CREDENTIALS_FILE="$HOME/.claude/.credentials.json"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo -e "${RED}Error: Claude credentials file not found at $CREDENTIALS_FILE${NC}"
    exit 1
fi

# Check if jq is installed for JSON parsing
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is not installed.${NC}"
    echo "Please install jq for JSON parsing: sudo apt-get install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

# Read credentials from JSON file
echo -e "${YELLOW}Reading Claude credentials...${NC}"
ACCESS_TOKEN=$(jq -r '.claudeAiOauth.accessToken' "$CREDENTIALS_FILE")
REFRESH_TOKEN=$(jq -r '.claudeAiOauth.refreshToken' "$CREDENTIALS_FILE")
EXPIRES_AT=$(jq -r '.claudeAiOauth.expiresAt' "$CREDENTIALS_FILE")

# Validate that all values were extracted
if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}Error: Could not extract access_token from credentials file${NC}"
    exit 1
fi

if [ "$REFRESH_TOKEN" == "null" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo -e "${RED}Error: Could not extract refresh_token from credentials file${NC}"
    exit 1
fi

if [ "$EXPIRES_AT" == "null" ] || [ -z "$EXPIRES_AT" ]; then
    echo -e "${RED}Error: Could not extract expires_at from credentials file${NC}"
    exit 1
fi

# Get current repository (will fail if not in a git repo)
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

# Get the repository name
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo -e "${YELLOW}Setting secrets for repository: $REPO${NC}"

# Set the secrets
echo -e "${YELLOW}Setting GitHub repository secrets...${NC}"

echo -n "Setting CLAUDE_ACCESS_TOKEN... "
if echo "$ACCESS_TOKEN" | gh secret set CLAUDE_ACCESS_TOKEN -R "$REPO"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo -n "Setting CLAUDE_REFRESH_TOKEN... "
if echo "$REFRESH_TOKEN" | gh secret set CLAUDE_REFRESH_TOKEN -R "$REPO"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo -n "Setting CLAUDE_EXPIRES_AT... "
if echo "$EXPIRES_AT" | gh secret set CLAUDE_EXPIRES_AT -R "$REPO"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo -e "${GREEN}Successfully set all Claude OAuth secrets!${NC}"
echo ""
echo "The following secrets have been added to your repository:"
echo "  - CLAUDE_ACCESS_TOKEN"
echo "  - CLAUDE_REFRESH_TOKEN"
echo "  - CLAUDE_EXPIRES_AT"
echo ""
echo "Your GitHub Actions workflows can now use OAuth authentication with Claude."