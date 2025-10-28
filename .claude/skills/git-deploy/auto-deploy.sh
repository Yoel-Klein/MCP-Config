#!/bin/bash
set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Analyzing changes...${NC}"

# Get commit message and deployment decision from smart-commit.py
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT=$(python3 "$SCRIPT_DIR/smart-commit.py")

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to generate commit message${NC}"
    exit 1
fi

# Parse output
MESSAGE=$(echo "$OUTPUT" | head -n 1)
DEPLOY_LINE=$(echo "$OUTPUT" | grep "DEPLOY_NEEDED" || echo "DEPLOY_NEEDED=false")
DEPLOY_NEEDED=$(echo "$DEPLOY_LINE" | cut -d= -f2)

echo -e "${GREEN}📝 Generated commit message:${NC} $MESSAGE"

# Stage all changes
echo -e "${BLUE}📦 Staging changes...${NC}"
git add .

# Commit
echo -e "${BLUE}💾 Committing...${NC}"
git commit -m "$MESSAGE"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Commit failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Committed successfully${NC}"

# Push to GitHub
echo -e "${BLUE}🚀 Pushing to GitHub (master)...${NC}"
git push origin master

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Push failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pushed to GitHub${NC}"

# Deploy if needed
if [ "$DEPLOY_NEEDED" = "true" ]; then
    echo -e "${BLUE}🚀 Deploying to production server...${NC}"

    # Run deployment script
    bash deploy_automated.sh

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Deployment successful${NC}"
        echo -e "${GREEN}🌐 Ready for testing at https://skyteksms.com${NC}"
    else
        echo -e "${RED}❌ Deployment failed - check logs${NC}"
        echo -e "${YELLOW}⚠️  Changes are committed but not deployed${NC}"
        echo -e "${YELLOW}💡 You can manually deploy with: bash deploy_automated.sh${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⏭️  Documentation/frontend-only change - skipping deployment${NC}"
    echo -e "${GREEN}✅ All done!${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Git Deploy Skill Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
