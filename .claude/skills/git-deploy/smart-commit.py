#!/usr/bin/env python3
"""
Smart Commit Message Generator
Analyzes git diff and generates conventional commit messages
OPTIMIZED: Uses efficient git commands to minimize token usage
"""
import subprocess
import sys
import re
from pathlib import Path

# Safeguard: Warn if too many files changed (prevents token waste)
MAX_FILES_WARNING = 50
MAX_DIFF_LINES = 500  # Limit diff content to prevent huge outputs


def run_git_command(args):
    """Run git command and return output"""
    try:
        result = subprocess.run(
            ['git'] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Git command failed: {e}", file=sys.stderr)
        return ""


def get_changed_files():
    """Get list of changed files from git status"""
    status = run_git_command(['status', '--porcelain'])
    files = []
    for line in status.split('\n'):
        if line.strip():
            # Format: "M  file.py" or "A  file.py"
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                files.append(parts[1])
    return files


def get_diff_stats():
    """Get diff statistics (optimized: limited width, no renames)"""
    return run_git_command(['diff', '--stat', '--stat-width=80', '--no-renames'])


def get_diff_content():
    """Get actual diff content (optimized: exclude binary files, limit output)"""
    # Exclude binary files (.tflite, .dll, .bin, .png, .jpg, etc.)
    # Use --unified=0 to reduce context lines (only show changed lines)
    diff = run_git_command(['diff', '--no-ext-diff', '--text', '--unified=1'])

    # Limit output to prevent token waste on huge diffs
    lines = diff.split('\n')
    if len(lines) > MAX_DIFF_LINES:
        # Take first 500 lines and add a warning
        diff = '\n'.join(lines[:MAX_DIFF_LINES])
        diff += f"\n... (diff truncated: {len(lines) - MAX_DIFF_LINES} lines omitted)"

    return diff


def should_deploy(changed_files):
    """Determine if deployment is needed based on changed files"""
    backend_patterns = [
        'backend/app/',
        'requirements.txt',
        'config.py',
        '.env.example'
    ]

    # Check if any backend files changed
    for file in changed_files:
        for pattern in backend_patterns:
            if pattern in file:
                return True

    return False


def determine_commit_type(changed_files, diff_content):
    """Determine conventional commit type based on changes"""

    # Check file types
    has_backend = any('backend/app/' in f for f in changed_files)
    has_docs = any(f.endswith('.md') for f in changed_files)
    has_frontend = any('static/' in f or 'templates/' in f for f in changed_files)

    # If only docs changed
    if has_docs and not has_backend and not has_frontend:
        return 'docs'

    # Check diff content for clues
    diff_lower = diff_content.lower()

    # Look for bug fix indicators
    if any(word in diff_lower for word in ['fix', 'bug', 'error', 'issue', 'crash', 'broken']):
        return 'fix'

    # Look for new features
    if any(word in diff_lower for word in ['def ', 'class ', 'async def', '@router']):
        # Check if it's a new function/class or modification
        if '+def ' in diff_content or '+class ' in diff_content or '+async def' in diff_content:
            return 'feat'

    # Look for refactoring
    if any(word in diff_lower for word in ['refactor', 'rename', 'restructure', 'cleanup']):
        return 'refactor'

    # Check for config/dependency changes
    if any(f in changed_files for f in ['requirements.txt', '.gitignore', 'config.py']):
        return 'chore'

    # Default based on file type
    if has_backend:
        return 'feat'  # Assume new backend work is a feature
    elif has_frontend:
        return 'style'

    return 'chore'


def extract_description(changed_files, diff_content):
    """Extract meaningful description from changes"""

    # Look for new function/class names
    new_functions = re.findall(r'\+\s*(?:async )?def (\w+)', diff_content)
    new_classes = re.findall(r'\+\s*class (\w+)', diff_content)

    if new_functions:
        return f"Add {new_functions[0]} function"
    if new_classes:
        return f"Add {new_classes[0]} class"

    # Look for modified routes
    route_changes = re.findall(r'@router\.(get|post|put|delete)\(["\']([^"\']+)', diff_content)
    if route_changes:
        method, path = route_changes[0]
        return f"Update {method.upper()} {path} endpoint"

    # Check file names for context
    if len(changed_files) == 1:
        file = changed_files[0]
        filename = Path(file).stem

        # Convert snake_case or kebab-case to readable
        readable = filename.replace('_', ' ').replace('-', ' ')
        return f"Update {readable}"

    # Multiple files - try to find common pattern
    if all('backend/app/services/' in f for f in changed_files):
        return "Update service layer"
    if all('backend/app/api/' in f for f in changed_files):
        return "Update API routes"
    if all('static/' in f for f in changed_files):
        return "Update frontend assets"
    if all('templates/' in f for f in changed_files):
        return "Update templates"

    # Generic based on file count
    if len(changed_files) <= 3:
        file_names = [Path(f).name for f in changed_files[:3]]
        return f"Update {', '.join(file_names)}"

    return f"Update {len(changed_files)} files"


def generate_commit_message():
    """Main function to generate commit message"""

    # Get changed files
    changed_files = get_changed_files()

    if not changed_files:
        print("No changes to commit", file=sys.stderr)
        return None, False

    # Safeguard: Warn if too many files changed
    if len(changed_files) > MAX_FILES_WARNING:
        print(f"WARNING: {len(changed_files)} files changed (>{MAX_FILES_WARNING})", file=sys.stderr)
        print(f"This may indicate missing .gitignore entries or bulk changes", file=sys.stderr)
        print(f"Consider reviewing with 'git status' before committing", file=sys.stderr)

    # Get diff content
    diff_content = get_diff_content()
    diff_stats = get_diff_stats()

    # Determine commit type
    commit_type = determine_commit_type(changed_files, diff_content)

    # Extract description
    description = extract_description(changed_files, diff_content)

    # Capitalize first letter of description
    description = description[0].upper() + description[1:] if description else "Update code"

    # Generate message
    message = f"{commit_type}: {description}"

    # Determine if deployment is needed
    needs_deploy = should_deploy(changed_files)

    return message, needs_deploy


if __name__ == '__main__':
    message, needs_deploy = generate_commit_message()

    if message:
        # Output format for bash script to parse
        print(message)
        print("DEPLOY_NEEDED=" + ("true" if needs_deploy else "false"))
    else:
        sys.exit(1)
