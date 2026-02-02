#!/bin/bash
#
# Claude Skills Validator
#
# Validates skill structure and content requirements
#
# Usage:
#   ./scripts/validate.sh skills/frontend/pwa-ui
#   ./scripts/validate.sh --all
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║     Claude Skills Validator           ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
  echo ""
}

error() {
  echo -e "  ${RED}✗${NC} ERROR: $1"
  ((ERRORS++))
}

warning() {
  echo -e "  ${YELLOW}!${NC} WARNING: $1"
  ((WARNINGS++))
}

success() {
  echo -e "  ${GREEN}✓${NC} $1"
}

info() {
  echo -e "  ${BLUE}→${NC} $1"
}

validate_skill() {
  local skill_path="$1"
  local skill_name=$(basename "$skill_path")

  echo ""
  echo -e "${BLUE}Validating: $skill_name${NC}"
  echo "─────────────────────────────────"

  # Check SKILL.md exists
  if [ ! -f "$skill_path/SKILL.md" ]; then
    error "SKILL.md not found"
    return 1
  fi
  success "SKILL.md exists"

  local skill_file="$skill_path/SKILL.md"

  # Check frontmatter
  if ! head -1 "$skill_file" | grep -q "^---$"; then
    error "Missing frontmatter (file must start with ---)"
  else
    success "Frontmatter present"
  fi

  # Check name in frontmatter
  if ! grep -q "^name:" "$skill_file"; then
    error "Missing 'name:' in frontmatter"
  else
    success "Name field present"
  fi

  # Check description in frontmatter
  if ! grep -q "^description:" "$skill_file"; then
    error "Missing 'description:' in frontmatter"
  else
    success "Description field present"

    # Check description includes trigger phrases
    local desc=$(grep -A5 "^description:" "$skill_file" | head -6)
    if ! echo "$desc" | grep -qi "when\|trigger\|use.*say"; then
      warning "Description should include trigger phrases"
    fi
  fi

  # Check line count
  local line_count=$(wc -l < "$skill_file")
  if [ "$line_count" -gt 500 ]; then
    warning "SKILL.md has $line_count lines (recommended: < 500)"
  else
    success "Line count OK ($line_count lines)"
  fi

  # Check for required sections
  if ! grep -q "^## Workflow\|^## When to Use" "$skill_file"; then
    warning "Missing 'Workflow' or 'When to Use' section"
  else
    success "Required sections present"
  fi

  # Check for code examples
  if ! grep -q '```' "$skill_file"; then
    warning "No code examples found (skills should include copy-paste ready code)"
  else
    local code_blocks=$(grep -c '```' "$skill_file" || echo 0)
    code_blocks=$((code_blocks / 2))
    success "Found $code_blocks code examples"
  fi

  # Check for patterns section
  if ! grep -q "^## Patterns\|^### Pattern" "$skill_file"; then
    warning "Missing 'Patterns' section"
  else
    success "Patterns section present"
  fi

  # Check references directory if mentioned
  if grep -q "references/" "$skill_file"; then
    if [ ! -d "$skill_path/references" ]; then
      error "References mentioned but references/ directory missing"
    else
      success "References directory exists"
    fi
  fi

  # Check assets directory if mentioned
  if grep -q "assets/" "$skill_file"; then
    if [ ! -d "$skill_path/assets" ]; then
      error "Assets mentioned but assets/ directory missing"
    else
      success "Assets directory exists"
    fi
  fi

  # Check for empty directories
  for dir in scripts references assets; do
    if [ -d "$skill_path/$dir" ]; then
      if [ -z "$(ls -A "$skill_path/$dir" 2>/dev/null)" ]; then
        warning "$dir/ directory is empty"
      fi
    fi
  done

  return 0
}

print_summary() {
  echo ""
  echo "─────────────────────────────────"
  echo -e "${BLUE}Summary${NC}"
  echo "─────────────────────────────────"

  if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
  else
    if [ $ERRORS -gt 0 ]; then
      echo -e "${RED}Errors: $ERRORS${NC}"
    fi
    if [ $WARNINGS -gt 0 ]; then
      echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    fi
  fi
  echo ""

  if [ $ERRORS -gt 0 ]; then
    exit 1
  fi
}

print_header

# Parse arguments
if [ "$1" = "--all" ]; then
  echo "Validating all skills..."

  for category_dir in skills/*/; do
    if [ -d "$category_dir" ]; then
      for skill_dir in "$category_dir"*/; do
        if [ -d "$skill_dir" ]; then
          validate_skill "$skill_dir"
        fi
      done
    fi
  done
elif [ -n "$1" ]; then
  if [ -d "$1" ]; then
    validate_skill "$1"
  else
    echo -e "${RED}Error: Directory not found: $1${NC}"
    exit 1
  fi
else
  echo "Usage: $0 <skill-path> | --all"
  echo ""
  echo "Examples:"
  echo "  $0 skills/frontend/pwa-ui"
  echo "  $0 --all"
  exit 1
fi

print_summary
