#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
expected_file_list="$repo_root/ci/expected-files.txt"
reports_dir="$repo_root/reports"
report_file="$reports_dir/validation-junit.xml"

mkdir -p "$reports_dir"

failures=0
failure_messages=()

if [[ ! -f "$expected_file_list" ]]; then
  failure_messages+=("Missing expected files list: ci/expected-files.txt")
  failures=$((failures + 1))
else
  while IFS= read -r rel_file || [[ -n "$rel_file" ]]; do
    [[ -z "$rel_file" ]] && continue
    if [[ ! -f "$repo_root/$rel_file" ]]; then
      failure_messages+=("Missing expected HTML file: $rel_file")
      failures=$((failures + 1))
      continue
    fi

    if command -v tidy >/dev/null 2>&1; then
      tidy_output="$(tidy -errors -q "$repo_root/$rel_file" 2>&1 || true)"
      if [[ -n "$tidy_output" ]]; then
        failure_messages+=("tidy validation issues in $rel_file: $tidy_output")
        failures=$((failures + 1))
      fi
    elif command -v xmllint >/dev/null 2>&1; then
      lint_output="$(xmllint --html --noout "$repo_root/$rel_file" 2>&1 || true)"
      if [[ -n "$lint_output" ]]; then
        failure_messages+=("xmllint warnings/errors in $rel_file: $lint_output")
        failures=$((failures + 1))
      fi
    else
      if ! python3 - "$repo_root/$rel_file" <<'PY'
from html.parser import HTMLParser
import pathlib
import sys

class Parser(HTMLParser):
    pass

path = pathlib.Path(sys.argv[1])
content = path.read_text(encoding="utf-8")
parser = Parser()
parser.feed(content)
parser.close()
PY
      then
        failure_messages+=("Python HTML parser could not parse $rel_file")
        failures=$((failures + 1))
      fi
    fi

    if ! grep -qi '<!DOCTYPE html>' "$repo_root/$rel_file"; then
      failure_messages+=("Missing <!DOCTYPE html> in $rel_file")
      failures=$((failures + 1))
    fi
    if ! grep -Eqi '<title>[^<]+</title>' "$repo_root/$rel_file"; then
      failure_messages+=("Missing non-empty <title> in $rel_file")
      failures=$((failures + 1))
    fi
    if ! grep -Eqi '<h1[^>]*>[^<]+</h1>' "$repo_root/$rel_file"; then
      failure_messages+=("Missing non-empty <h1> in $rel_file")
      failures=$((failures + 1))
    fi
  done < "$expected_file_list"
fi

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo "<testsuite name=\"html-validation\" tests=\"1\" failures=\"$failures\">"
  echo '  <testcase classname="ci.validation" name="validate-html-files">'
  if (( failures > 0 )); then
    printf '    <failure message="HTML validation failed"><![CDATA['
    printf '%s\n' "${failure_messages[@]}"
    echo ']]></failure>'
  fi
  echo '  </testcase>'
  echo '</testsuite>'
} > "$report_file"

if (( failures > 0 )); then
  printf 'HTML validation failed:\n' >&2
  printf ' - %s\n' "${failure_messages[@]}" >&2
  exit 1
fi

echo "HTML validation passed"
