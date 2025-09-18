#!/bin/bash

# max time curl waits for a response
TIMEOUT=10

extract_links() {
  local file="$1"
  grep -oE 'link:https?://[^[]+' "$file"
}

check_url_status() {
  local url="$1"
  curl -o /dev/null --silent --head --write-out "%{http_code}" --max-time "$TIMEOUT" -L "$url"
}

handle_status_code() {
  local status="$1"
  local url="$2"
  local file="$3"

    case "$status" in
      2*|3*)
        return 0
        ;;  # 200 or 300 status codes are all good, do nothing
      4*)
        # 400 status codes are bad, we care about fixing these
        echo "❌Broken link in $file: $url (HTTP $status)"
        return 1
        ;;
      5*)
        # 500 status codes are good to note, but we do not care about these
        echo "⚠️ Server error in $file: $url (HTTP $status)"
        return 2
        ;;
      *)
        # anything else, do not care
        echo "❓Unexpected status for $url in $file: HTTP $status"
        return 2
        ;;
    esac
}

summarize_results() {
  local file="$1"
  local client_errors="$2"
  local server_errors="$3"

  if [[ $client_errors -eq 0 && $server_errors -eq 0 ]]; then
    echo "✅ No broken links in $file"
  elif [[ $client_errors -eq 0 && $server_errors -eq 1 ]]; then
    echo "⚠️ Only server-side errors in $file"
  fi
}

# check a file for broken URLs
check_links_in_file() {
  local file="$1"
  local has_client_errors=0
  local has_server_errors=0

  [[ ! -f "$file" ]] && {
    echo "❌ File not found: $file"
    return
  }

  # extract links
  while read -r link; do
    url="${link#link:}"
    status=$(check_url_status "$url")
    handle_status_code "$status" "$url" "$file"
    case $? in
      1) has_client_errors=1 ;;
      2) has_server_errors=1 ;;
    esac
  done < <(extract_links "$file")

  summarize_results "$file" "$has_client_errors" "$has_server_errors"
}

main() {
  # if no arguments, read from stdin
  # e.g. cat filenames.txt | ./check-links.sh
  if [[ $# -eq 0 ]]; then
    while read -r file; do
      check_links_in_file "$file"
    done
  # if arguments, read array
  # e.g. ./check-links.sh file1.adoc file2.adoc
  else
    for file in "$@"; do
      check_links_in_file "$file"
    done
  fi
}

main "$@"
