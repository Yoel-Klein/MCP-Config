# Centralized Claude MCP Configuration

This repository contains my centralized Claude Code MCP (Model Context Protocol) configuration, allowing consistent settings across all projects and computers.

## Overview

Instead of managing `.claude` folders in each project (which clutters Git repos), this approach:
- Centralizes all MCP configuration in one place
- Syncs settings across multiple computers via Git
- Uses symlinks in projects to reference the central config
- Keeps project repos clean

## Directory Structure

```
C:\MCP-Config\
├── .claude\
│   ├── mcp.json                # MCP server configurations
│   ├── settings.json           # Global Claude Code settings
│   ├── settings.local.json     # Machine-specific overrides
│   ├── agents\                 # Custom agent definitions
│   ├── skills\                 # Custom skills
│   └── mcp-profiles\           # MCP profile configurations
├── setup-symlink.bat           # Windows setup script
├── setup-symlink.sh            # Unix/Mac/Git Bash setup script
└── README.md                   # This file
```

## Initial Setup

### On Your First Computer (Already Done)

1. ✅ Created `C:\MCP-Config\` directory
2. ✅ Moved `.claude` configuration here
3. ✅ Initialized Git repository
4. Next: Push to GitHub (see instructions below)

### On Additional Computers

1. **Clone this repo**:
   ```bash
   git clone <your-github-url> C:\MCP-Config
   ```

2. **Run setup script in each project**:

   **Windows (PowerShell/CMD as Administrator):**
   ```batch
   cd C:\Projects\YourProject
   C:\MCP-Config\setup-symlink.bat
   ```

   **Git Bash/Linux/Mac:**
   ```bash
   cd ~/Projects/YourProject
   bash /c/MCP-Config/setup-symlink.sh
   ```

   **Note**: On Windows, you need to run as Administrator to create directory symlinks.

## Setting Up a New Project

When you clone or create a new project:

1. Navigate to the project directory
2. Run the setup script:
   ```batch
   # Windows (as Administrator)
   C:\MCP-Config\setup-symlink.bat

   # Or Unix/Mac
   bash /c/MCP-Config/setup-symlink.sh
   ```
3. The script will create a `.claude` symlink pointing to `C:\MCP-Config\.claude`
4. Ensure `.claude` is in your project's `.gitignore`

## Updating .gitignore in Projects

Add this to your project's `.gitignore`:

```gitignore
# Claude Code configuration (managed via symlink to centralized config)
.claude/
```

## MCP Configuration Files

### `mcp.json`
Defines MCP servers and their configurations:
- chrome-devtools: Chrome DevTools integration
- context7: Context management tool
- Add more as needed

### `settings.json`
Global Claude Code settings that apply across all projects.

### `settings.local.json`
Machine-specific overrides that won't be synced to Git (add to `.gitignore` if needed).

## Benefits

✅ **Single Source of Truth**: One config for all projects
✅ **Consistent MCP Setup**: Same servers across projects
✅ **Easy Updates**: Change once, affects all projects
✅ **Clean Project Repos**: No .claude folders in project Git
✅ **Multi-Computer Sync**: Git keeps configs in sync
✅ **Per-Project Overrides**: Still possible via local settings

## Advanced Usage

### Per-Project Overrides

If a specific project needs different settings:

1. Remove the symlink: `rd .claude` (Windows) or `rm .claude` (Unix)
2. Copy the central config: `cp -r C:\MCP-Config\.claude .claude`
3. Modify as needed
4. Add `.claude` to that project's `.gitignore`

### Machine-Specific Settings

Use `settings.local.json` for settings that differ per machine (e.g., local paths, API keys).

### Adding New MCP Servers

1. Edit `C:\MCP-Config\.claude\mcp.json`
2. Commit and push changes
3. Pull on other computers
4. All projects automatically get the new server

## GitHub Setup

### Create GitHub Repository

```bash
cd C:\MCP-Config
git add .
git commit -m "Initial commit: Centralized Claude MCP configuration"

# Create repo on GitHub, then:
git remote add origin <your-github-url>
git branch -M main
git push -u origin main
```

### Syncing Across Computers

```bash
# Pull latest changes
cd C:\MCP-Config
git pull

# Push your changes
cd C:\MCP-Config
git add .
git commit -m "Updated MCP configuration"
git push
```

## Troubleshooting

### "Access Denied" on Windows

Directory symlinks require Administrator privileges. Right-click the script and "Run as administrator".

### Symlink Not Working

Verify the symlink:
```bash
# Windows
dir .claude

# Unix/Mac
ls -la .claude
```

It should show `<SYMLINK>` or `->` pointing to the central config.

### MCP Servers Not Loading

1. Check symlink is correctly pointing to `C:\MCP-Config\.claude`
2. Verify `mcp.json` is valid JSON
3. Restart Claude Code
4. Check Claude Code logs for errors

## Migration Checklist

- [x] Create C:\MCP-Config directory
- [x] Move .claude folder
- [x] Initialize Git repo
- [x] Create setup scripts
- [ ] Create GitHub repo and push
- [ ] Test symlink in first project
- [ ] Update project .gitignore
- [ ] Remove old .claude from project Git history (optional)
- [ ] Set up on other computers

## Security Notes

⚠️ **Do NOT commit sensitive data** to this repo:
- API keys
- Authentication tokens
- Passwords

Use environment variables or `settings.local.json` (add to `.gitignore` in this repo) for sensitive configs.

## Questions or Issues?

If you encounter issues:
1. Check symlink is created correctly
2. Verify administrator privileges on Windows
3. Ensure paths match your setup (adjust scripts if needed)
4. Check Claude Code documentation for latest MCP changes

---

**Last Updated**: October 2025
