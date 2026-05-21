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

get_nth_line() {
  echo $1 | sed -n $2'p'
}

test_should_guarantee_correct_permission_on_first_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 2) | read permission _
  cd ..

  expected_permission="drwx--xr-x"

  assert_str_eq $expected_permission $permission "on file test0"

  remove_test_files
}

test_should_guarantee_two_hard_links_on_first_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 2) | read permission hard_links _
  cd ..

  expected_hard_links=2

  assert_str_eq $expected_hard_links $hard_links "on file test0"

  remove_test_files
}

test_should_guarantee_correct_timestamp_on_first_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 2) | read permission hard_links owner group bytes month day hour name
  cd ..

  expected_month="Jun"
  expected_day=1
  expected_hour='20:47'
  if [ "$expected_hour" != "$hour" ]; then
    expected_hour="2025"
  fi

  assert_str_eq $expected_month $month "on file test0"
  assert_str_eq $expected_day $day "on file test0"
  assert_str_eq $expected_hour $hour "on file test0"

  remove_test_files
}

test_should_guarantee_correct_name_for_first_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 2) | read p h o g b m d ho name
  cd ..

  expected_name=test0

  assert_str_eq $expected_name $name

  remove_test_files
}

test_should_guarantee_correct_permission_on_test1_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1
  fi

  expected_permission="-rwx--xr--"
  cd test_files
  echo $(get_nth_line "$(ls -l)" 3) | read permission _
  cd ..

  assert_str_eq $expected_permission $permission

  remove_test_files
}

test_should_guarantee_correct_bytes_on_test1_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 3) | read permission hl o g bytes _
  cd ..

  expected_bytes=4

  assert_str_eq $expected_bytes $bytes

  remove_test_files
}

test_should_guarantee_correct_timestamps_on_test1_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 3) | read permission hl o g bytes month day hour _
  cd ..

  expected_month=Jun
  expected_day=1
  expected_hour="21:46"
  if [ $hour != $expected_hour ]; then
    expected_hour=2025
  fi

  assert_str_eq $expected_month $month
  assert_str_eq $expected_day $day
  assert_str_eq $expected_hour $hour

  remove_test_files
}

test_should_guarantee_correct_test1_files_name() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 3) | read permission hl o g bytes month day hour name
  cd ..

  expected_name=test1

  assert_str_eq $expected_name $name

  remove_test_files
}

test_should_guarantee_correct_test2_permissions() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 4) | read permission _
  cd ..

  expected_permission="dr-x---r--"

  assert_str_eq $expected_permission $permission

  remove_test_files
}

test_should_guarantee_correct_timestamps_on_test2_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 4) | read permission hl o g bytes month day hour _
  cd ..

  expected_month=Jun
  expected_day=1
  expected_hour="22:45"
  if [ $hour != $expected_hour ]; then
    expected_hour=2025
  fi

  assert_str_eq $expected_month $month
  assert_str_eq $expected_day $day
  assert_str_eq $expected_hour $hour

  remove_test_files
}

test_should_guarantee_correct_name_for_test2_dir() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 4) | read permission hl o g bytes month day hour name
  cd ..

  expected_name=test2
  assert_str_eq $expected_name $name

  remove_test_files
}

test_should_guarantee_correct_permission_on_test3() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 5) | read permission _
  cd ..

  expected_permission="-r-----r--"

  assert_str_eq $expected_permission $permission

  remove_test_files
}

test_should_guarantee_correct_hardlinks_on_test3() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 5) | read permission hardlinks _
  cd ..

  expected_harlinks=2

  assert_str_eq $expected_harlinks $hardlinks

  remove_test_files
}

test_should_guarantee_correct_bytes_on_test3() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 5) | read permission hardlinks o g bytes _
  cd ..

  expected_bytes=1

  assert_str_eq $expected_bytes $bytes

  remove_test_files
}

test_should_guarantee_correct_timestamps_on_test3_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 5) | read permission hl o g bytes month day hour _
  cd ..

  expected_month=Jun
  expected_day=1
  expected_hour="23:44"
  if [ $hour != $expected_hour ]; then
    expected_hour=2025
  fi

  assert_str_eq $expected_month $month
  assert_str_eq $expected_day $day
  assert_str_eq $expected_hour $hour

  remove_test_files
}

test_should_guarantee_correct_name_on_test4_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 6) | read permission hl o g bytes month day hour name
  cd ..

  expected_name="test4"

  assert_str_eq $expected_name $name

  remove_test_files
}

test_should_guarantee_correct_permission_on_test4() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 6) | read permission _
  cd ..

  expected_permission="-rw-r----x"

  assert_str_eq $expected_permission $permission

  remove_test_files
}

test_should_guarantee_correct_bytes_on_test4() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 6) | read permission hardlinks o g bytes _
  cd ..

  expected_bytes=2

  assert_str_eq $expected_bytes $bytes

  remove_test_files
}

test_should_guarantee_correct_timestamps_on_test4_file() {
  create_test_files
  if [ $? -eq 1 ]; then
    return 1;
  fi
  cd test_files
  echo $(get_nth_line "$(ls -l)" 6) | read permission hl o g bytes month day hour _
  cd ..

  expected_month=Jun
  expected_day=1
  expected_hour="23:43"
  if [ $hour != $expected_hour ]; then
    expected_hour=2025
  fi

  assert_str_eq $expected_month $month
  assert_str_eq $expected_day $day
  assert_str_eq $expected_hour $hour

  remove_test_files
}

test_should_guarantee_correct_permission_on_first_file
test_should_guarantee_two_hard_links_on_first_file
test_should_guarantee_correct_timestamp_on_first_file
test_should_guarantee_correct_name_for_first_file
test_should_guarantee_correct_permission_on_test1_file
test_should_guarantee_correct_bytes_on_test1_file
test_should_guarantee_correct_timestamps_on_test1_file
test_should_guarantee_correct_test1_files_name
test_should_guarantee_correct_test2_permissions
test_should_guarantee_correct_timestamps_on_test2_file
test_should_guarantee_correct_permission_on_test3
test_should_guarantee_correct_hardlinks_on_test3
test_should_guarantee_correct_bytes_on_test3
test_should_guarantee_correct_timestamps_on_test3_file
test_should_guarantee_correct_name_on_test4_file
test_should_guarantee_correct_permission_on_test4
test_should_guarantee_correct_bytes_on_test4
test_should_guarantee_correct_timestamps_on_test4_file
