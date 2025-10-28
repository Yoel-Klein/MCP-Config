#!/bin/bash
# Setup script to create .claude symlink in a project directory
# Usage: ./setup-symlink.sh [project-path]
# If no path provided, uses current directory

set -e

# Determine project directory
if [ -z "$1" ]; then
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="$1"
fi

# MCP config directory (adjust path for your OS)
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash)
    MCP_CONFIG_DIR="/c/MCP-Config/.claude"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    MCP_CONFIG_DIR="$HOME/MCP-Config/.claude"
else
    # Linux
    MCP_CONFIG_DIR="$HOME/MCP-Config/.claude"
fi

SYMLINK_TARGET="$PROJECT_DIR/.claude"

echo ""
echo "========================================"
echo "Claude MCP Symlink Setup"
echo "========================================"
echo ""
echo "Project Directory: $PROJECT_DIR"
echo "MCP Config Source:  $MCP_CONFIG_DIR"
echo "Symlink Target:     $SYMLINK_TARGET"
echo ""

# Check if MCP config exists
if [ ! -d "$MCP_CONFIG_DIR" ]; then
    echo "ERROR: MCP config directory not found at $MCP_CONFIG_DIR"
    echo "Please ensure the MCP config directory exists"
    exit 1
fi

# Check if symlink already exists
if [ -e "$SYMLINK_TARGET" ]; then
    echo "WARNING: .claude already exists at $SYMLINK_TARGET"
    echo ""
    read -p "Do you want to remove it and create a symlink? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    # Remove existing .claude
    rm -rf "$SYMLINK_TARGET"
fi

# Create symbolic link
echo "Creating symlink..."
ln -s "$MCP_CONFIG_DIR" "$SYMLINK_TARGET"

if [ $? -eq 0 ]; then
    echo ""
    echo "SUCCESS! Symlink created successfully."
    echo ""
    echo "Your project now uses the centralized MCP configuration."
    echo "Any changes to .claude files will be reflected across all projects."
    echo ""
else
    echo ""
    echo "ERROR: Failed to create symlink."
    exit 1
fi
