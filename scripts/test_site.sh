#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
index_file="$repo_root/index.html"
reports_dir="$repo_root/reports"
report_file="$reports_dir/site-tests-junit.xml"

mkdir -p "$reports_dir"

failures=0
failure_messages=()

if [[ ! -f "$index_file" ]]; then
  failure_messages+=("Missing index.html")
  failures=$((failures + 1))
else
  if ! grep -q "Welcome to My Page" "$index_file"; then
    failure_messages+=("index.html is missing expected welcome header text")
    failures=$((failures + 1))
  fi
  if ! grep -q "sample paragraph" "$index_file"; then
    failure_messages+=("index.html is missing expected sample paragraph text")
    failures=$((failures + 1))
  fi
  if grep -q "TODO" "$index_file"; then
    failure_messages+=("index.html still contains TODO placeholder text")
    failures=$((failures + 1))
  fi
fi

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo "<testsuite name=\"site-content-tests\" tests=\"1\" failures=\"$failures\">"
  echo '  <testcase classname="ci.tests" name="check-site-content">'
  if (( failures > 0 )); then
    printf '    <failure message="Site content checks failed"><![CDATA['
    printf '%s\n' "${failure_messages[@]}"
    echo ']]></failure>'
  fi
  echo '  </testcase>'
  echo '</testsuite>'
} > "$report_file"

if (( failures > 0 )); then
  printf 'Site content checks failed:\n' >&2
  printf ' - %s\n' "${failure_messages[@]}" >&2
  exit 1
fi

echo "Site content tests passed"
