#!/bin/bash
#
# Claude Skills Installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/naik-ai/skills/main/scripts/install.sh | bash
#
#   Or locally:
#   ./scripts/install.sh [--all | --skill SKILL_NAME]
#

set -e

# Configuration
REPO_URL="${SKILLS_REPO_URL:-https://github.com/naik-ai/skills}"
TARGET_DIR="${SKILLS_TARGET_DIR:-.claude/skills}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║     Claude Skills Installer           ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
  echo ""
}

print_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --all              Install all skills"
  echo "  --skill NAME       Install specific skill (e.g., pwa-ui)"
  echo "  --list             List available skills"
  echo "  --help             Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 --all"
  echo "  $0 --skill pwa-ui"
  echo "  $0 --skill react-best-practices"
  echo ""
}

# Parse arguments
INSTALL_ALL=false
SKILL_NAME=""
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --all)
      INSTALL_ALL=true
      shift
      ;;
    --skill)
      SKILL_NAME="$2"
      shift 2
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --help)
      print_usage
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      print_usage
      exit 1
      ;;
  esac
done

print_header

# Check if we're in a project directory
check_project() {
  if [ -f "package.json" ] || [ -f "Cargo.toml" ] || [ -f "go.mod" ] || \
     [ -f "pyproject.toml" ] || [ -f "Gemfile" ] || [ -f "pom.xml" ] || \
     [ -f "build.gradle" ] || [ -f "Makefile" ]; then
    return 0
  fi
  return 1
}

if ! check_project && [ "$LIST_ONLY" = false ]; then
  echo -e "${YELLOW}Warning: No project file detected (package.json, pyproject.toml, etc.)${NC}"
  read -p "Continue anyway? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Create temp directory for clone
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${YELLOW}Fetching skills repository...${NC}"
git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR"

# List skills function
list_skills() {
  echo "Available Skills:"
  echo "─────────────────"
  echo ""
  for skill_dir in "$TEMP_DIR/skills/"*/; do
    if [ -f "${skill_dir}SKILL.md" ]; then
      skill_name=$(basename "$skill_dir")
      description=$(grep -A1 "^description:" "${skill_dir}SKILL.md" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//' | cut -c1-60)
      echo -e "  ${GREEN}•${NC} $skill_name"
      if [ -n "$description" ]; then
        echo "    $description..."
      fi
    fi
  done
  echo ""
}

if [ "$LIST_ONLY" = true ]; then
  list_skills
  exit 0
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Find and copy skills
copy_skill() {
  local skill_path="$1"
  local skill_name=$(basename "$skill_path")

  if [ -f "${skill_path}/SKILL.md" ]; then
    cp -r "$skill_path" "$TARGET_DIR/"
    echo -e "  ${GREEN}✓${NC} Installed: $skill_name"
    return 0
  fi
  return 1
}

find_skill() {
  local name="$1"
  if [ -d "$TEMP_DIR/skills/$name" ]; then
    echo "$TEMP_DIR/skills/$name"
    return 0
  fi
  return 1
}

# Install based on options
if [ "$INSTALL_ALL" = true ]; then
  echo -e "${YELLOW}Installing all skills...${NC}"
  echo ""
  for skill_dir in "$TEMP_DIR/skills/"*/; do
    if [ -d "$skill_dir" ] && [ -f "${skill_dir}SKILL.md" ]; then
      copy_skill "$skill_dir"
    fi
  done
elif [ -n "$SKILL_NAME" ]; then
  echo -e "${YELLOW}Installing skill: $SKILL_NAME${NC}"
  echo ""
  skill_path=$(find_skill "$SKILL_NAME")
  if [ -n "$skill_path" ]; then
    copy_skill "$skill_path"
  else
    echo -e "${RED}Skill not found: $SKILL_NAME${NC}"
    echo ""
    echo "Available skills:"
    list_skills
    exit 1
  fi
else
  # Default: install all
  echo -e "${YELLOW}Installing all skills (use --help for options)...${NC}"
  echo ""
  for skill_dir in "$TEMP_DIR/skills/"*/; do
    if [ -d "$skill_dir" ] && [ -f "${skill_dir}SKILL.md" ]; then
      copy_skill "$skill_dir"
    fi
  done
fi

echo ""
echo -e "${GREEN}✅ Skills installed to $TARGET_DIR${NC}"
echo ""
echo "Usage:"
echo "  Skills are automatically available to Claude Code."
echo "  Describe your task and relevant skills will be used."
echo ""
echo "Examples:"
echo '  "Create a mobile-first dashboard"      → pwa-ui'
echo '  "Build a server component with data"   → react-best-practices'
echo '  "Design a user schema with migrations" → postgres-fastapi'
echo ""
