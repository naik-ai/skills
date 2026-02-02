#!/usr/bin/env python3
"""
Spec Validator
Validates that generated specification documents have all required sections
and meet quality standards.

Usage:
    python spec-validator.py docs/specs/feature-spec.md
    python spec-validator.py --quick docs/specs/quick-spec.md
"""

import sys
import re
import argparse
from pathlib import Path

# Required sections for full spec
FULL_SPEC_SECTIONS = [
    "Overview",
    "User Stories",
    "Technical",
    "UI/UX",
    "Edge Cases",
    "Security",
    "Performance",
    "Implementation",
]

# Required sections for quick spec
QUICK_SPEC_SECTIONS = [
    "What",
    "Why",
    "How",
    "Acceptance Criteria",
]

# Quality checks
QUALITY_PATTERNS = {
    "unresolved_placeholders": r'\[(TODO|TBD|PLACEHOLDER|XXX|FIXME)\]',
    "empty_tables": r'\|\s*\|\s*\|',
    "missing_acceptance_criteria": r'- \[ \] \[',  # Empty checkbox with placeholder
    "vague_language": r'\b(maybe|probably|might|could|should consider|etc\.)\b',
}

def validate_sections(content: str, required_sections: list) -> tuple[list, list]:
    """Check that all required sections are present."""
    found = []
    missing = []

    for section in required_sections:
        # Match "## 1. Section" or "## Section" or "### Section"
        pattern = rf'##\s+\d*\.?\s*{section}'
        if re.search(pattern, content, re.IGNORECASE):
            found.append(section)
        else:
            missing.append(section)

    return found, missing

def check_quality(content: str) -> dict:
    """Run quality checks on the content."""
    issues = {}

    for check_name, pattern in QUALITY_PATTERNS.items():
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            issues[check_name] = len(matches)

    return issues

def count_acceptance_criteria(content: str) -> int:
    """Count the number of acceptance criteria."""
    # Match "- [ ] Something" or "- [x] Something"
    criteria = re.findall(r'- \[[x ]\] .+', content, re.IGNORECASE)
    return len(criteria)

def check_code_blocks(content: str) -> int:
    """Count code blocks (indicates technical detail)."""
    blocks = re.findall(r'```', content)
    return len(blocks) // 2  # Divide by 2 for opening/closing

def check_tables(content: str) -> int:
    """Count tables (indicates structured information)."""
    # Tables have | at start of line
    table_rows = re.findall(r'^\|.+\|$', content, re.MULTILINE)
    return len(table_rows)

def validate_spec(filepath: str, quick: bool = False) -> bool:
    """Validate a specification file."""
    path = Path(filepath)

    if not path.exists():
        print(f"❌ File not found: {filepath}")
        return False

    content = path.read_text()

    print(f"\n📄 Validating: {filepath}")
    print("=" * 50)

    # Choose section requirements based on spec type
    required = QUICK_SPEC_SECTIONS if quick else FULL_SPEC_SECTIONS

    # Check sections
    found, missing = validate_sections(content, required)

    if missing:
        print(f"\n❌ Missing sections ({len(missing)}):")
        for section in missing:
            print(f"   • {section}")
    else:
        print(f"\n✅ All {len(required)} required sections present")

    # Quality checks
    issues = check_quality(content)

    if issues:
        print(f"\n⚠️  Quality issues found:")
        for issue, count in issues.items():
            issue_name = issue.replace('_', ' ').title()
            print(f"   • {issue_name}: {count} instance(s)")
    else:
        print(f"\n✅ No quality issues detected")

    # Stats
    criteria_count = count_acceptance_criteria(content)
    code_blocks = check_code_blocks(content)
    tables = check_tables(content)
    line_count = len(content.split('\n'))

    print(f"\n📊 Statistics:")
    print(f"   • Lines: {line_count}")
    print(f"   • Acceptance criteria: {criteria_count}")
    print(f"   • Code blocks: {code_blocks}")
    print(f"   • Table rows: {tables}")

    # Recommendations
    print(f"\n💡 Recommendations:")

    if criteria_count < 3:
        print(f"   • Add more acceptance criteria (currently {criteria_count})")

    if code_blocks < 2 and not quick:
        print(f"   • Add more code examples (currently {code_blocks})")

    if tables < 3 and not quick:
        print(f"   • Consider using tables for structured data")

    if line_count < 100 and not quick:
        print(f"   • Spec seems brief ({line_count} lines) - consider adding more detail")

    if line_count > 500:
        print(f"   • Spec is long ({line_count} lines) - consider splitting")

    # Final verdict
    print(f"\n{'=' * 50}")

    has_critical_issues = len(missing) > 0 or 'unresolved_placeholders' in issues

    if has_critical_issues:
        print(f"❌ Validation FAILED - address critical issues above")
        return False
    elif issues:
        print(f"⚠️  Validation PASSED with warnings")
        return True
    else:
        print(f"✅ Validation PASSED")
        return True

def main():
    parser = argparse.ArgumentParser(
        description='Validate specification documents',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s docs/specs/feature-spec.md
  %(prog)s --quick docs/specs/bug-fix.md
  %(prog)s docs/specs/*.md
        """
    )

    parser.add_argument(
        'files',
        nargs='+',
        help='Specification file(s) to validate'
    )

    parser.add_argument(
        '--quick',
        action='store_true',
        help='Validate as quick spec (fewer required sections)'
    )

    args = parser.parse_args()

    all_passed = True

    for filepath in args.files:
        if not validate_spec(filepath, args.quick):
            all_passed = False

    sys.exit(0 if all_passed else 1)

if __name__ == "__main__":
    main()
