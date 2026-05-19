#!/bin/zsh

assert_str_eq() {
  if [ "$1" != "$2" ]; then
    # Print error to stderr
    echo "❌ FAIL: ${3:-Assertion failed}" >&2
    echo "   Expected: '$1'" >&2
    echo "   Actual:   '$2'" >&2
  else
    echo -n "✅"
  fi
}

check_file() {
  if [ ! -f "$1" ]; then
    echo "File $1 does not exist." >&2
   return 1
  fi

  return 0
}

create_test_files() {
  check_file "exo.tar"

  if [ $? -eq "1" ]; then
    return 1;
  fi

  mkdir test_files
  cp "exo.tar" test_files
  cd test_files
  tar -xpf "exo.tar" > /dev/null
  rm -rf exo.tar
  cd ..

  return 0;
}

remove_test_files() {
  rm -rf test_files
}
