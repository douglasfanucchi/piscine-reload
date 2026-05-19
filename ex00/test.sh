#!/bin/zsh

assert_str_eq() {
  if [ "$1" != "$2" ]; then
    # Print error to stderr
    echo "❌ FAIL: ${3:-Assertion failed}" >&2
    echo "   Expected: '$1'" >&2
    echo "   Actual:   '$2'" >&2
    exit 1
  else
    echo "✅"
  fi
}

check_file() {
  if [ ! -f "$1" ]; then
    echo "File $1 does not exist." >&2
   return 1
  fi

  return 0
}
