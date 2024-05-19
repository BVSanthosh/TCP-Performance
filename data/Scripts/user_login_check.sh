#!/bin/bash

# Check for users logged in on lab-clients.
# Not completely definitive, but good enough.
# saleem: 20230914, 20230207, 20220202, 20210801

# If you have a SSH key set-up on your server login on:
#
#   <username>.teaching.cs.st-andrews.ac.uk
#
# and run this from that server, things should just work.

# Otherwise, this script will not work.
# Either you will get "timeout" messages for all attempts, or you will
# get a login prompt for each remote machine!

# Machine names screen-scraped from the URL below on 20230914 14:00.
# https://wiki.cs.st-andrews.ac.uk/index.php?title=Lab_PCs#Lab_PC_hostnames
# pc1, pc7, and pc8 machines are generally usable.
# pc9 machines are not included : they are to be used for GPU work only.

# #### ####
# ssh timeout values ...
timeout_ns=8000000000 # nanoseconds, use with "date +%N", arbitrary choice of value.
timeout_s=$((timeout_ns / 1000000000)) # seconds for use with timeout

# #### ####
# lab ("client") host names
lab_hosts_test=(pc7-003-l pc7-004-l pc7-005-l pc7-006-l pc7-011-l pc7-012-l pc7-013-l pc7-014-l pc7-017-l pc7-018-l)

all_usable_lab_hosts=(pc1-001-l pc1-002-l pc1-003-l pc1-004-l pc1-005-l pc1-006-l pc1-007-l pc1-008-l pc1-009-l pc1-010-l pc1-011-l pc1-012-l pc1-013-l pc1-014-l pc1-015-l pc1-016-l pc1-017-l pc1-018-l pc1-019-l pc1-020-l pc1-021-l pc1-022-l pc1-023-l pc1-024-l pc1-025-l pc1-026-l pc1-027-l pc1-028-l pc1-029-l pc1-030-l pc1-031-l pc1-032-l pc1-033-l pc1-034-l pc1-035-l pc1-036-l pc1-037-l pc1-038-l pc7-003-l pc7-004-l pc7-005-l pc7-006-l pc7-011-l pc7-012-l pc7-013-l pc7-014-l pc7-017-l pc7-018-l pc7-020-l pc7-023-l pc7-025-l pc7-026-l pc7-027-l pc7-028-l pc7-029-l pc7-036-l pc7-039-l pc7-043-l pc7-045-l pc7-050-l pc7-052-l pc7-054-l pc7-055-l pc7-056-l pc7-057-l pc7-059-l pc7-062-l pc7-063-l pc7-064-l pc7-066-l pc7-067-l pc7-070-l pc7-071-l pc7-073-l pc7-074-l pc7-075-l pc7-076-l pc7-078-l pc7-082-l pc7-085-l pc7-087-l pc7-089-l pc7-091-l pc7-092-l pc7-093-l pc7-094-l pc7-097-l pc7-098-l pc7-100-l pc7-103-l pc7-106-l pc7-109-l pc7-112-l pc7-113-l pc7-114-l pc7-116-l pc7-117-l pc7-119-l pc7-120-l pc7-121-l pc7-122-l pc7-123-l pc7-129-l pc7-133-l pc7-134-l pc7-135-l pc7-136-l pc7-139-l pc7-140-l pc7-145-l pc7-146-l pc7-147-l pc7-148-l pc7-149-l pc7-150-l pc8-001-l pc8-002-l pc8-003-l pc8-004-l pc8-005-l pc8-006-l pc8-007-l pc8-008-l pc8-009-l pc8-010-l pc8-011-l pc8-012-l pc8-013-l pc8-014-l pc8-015-l pc8-016-l pc8-017-l pc8-018-l pc8-019-l pc8-020-l pc8-021-l pc8-022-l pc8-023-l pc8-024-l pc8-025-l pc8-026-l pc8-027-l pc8-028-l pc8-029-l pc8-030-l pc8-031-l pc8-032-l pc8-033-l pc8-034-l pc8-035-l pc8-036-l pc8-037-l pc8-038-l pc8-039-l pc8-040-l pc8-041-l pc8-042-l pc8-043-l pc8-044-l pc8-045-l pc8-046-l pc8-047-l pc8-048-l pc8-049-l pc8-050-l pc8-051-l pc8-052-l pc8-053-l pc8-054-l pc8-055-l pc8-056-l pc8-057-l pc8-058-l pc8-059-l pc8-060-l pc8-061-l pc8-062-l pc8-063-l pc8-064-l pc8-066-l pc8-067-l pc8-068-l pc8-069-l pc8-070-l pc8-071-l pc8-072-l pc8-073-l pc8-074-l pc8-075-l pc8-076-l pc8-077-l pc8-078-l)

#names=(${lab_hosts_test[*]})
names=(${all_usable_lab_hosts[*]})

# #### ####
# main
no_users_msg="--"
timeout_msg="(timeout: either booted in windows or possibly down)"

hosts_up=0
hosts_down=0
hosts_free=0
hosts_free_list=""
m=${#names[@]}
now=$(date)

printf 'Started on %s.\n' "$now"
printf '%s lab hosts to check ...\n' $m

start_time=$(date +%s)
for n in "${names[@]}"
do
  printf '%4s %6s ' $m $n

  epoch0=$(date +%s%N)
  users=$(timeout $timeout_s ssh $n.cs.st-andrews.ac.uk users)
  epoch1=$(date +%s%N)
  e=$((epoch1 - epoch0))

  if [ $e -gt $timeout_ns ] # timeout of ssh attempt
  then
    hosts_down=$((hosts_down + 1))
    printf ' %s' $timeout_msg
  else
    hosts_up=$((hosts_up + 1))
    if [ -z "$users" ]
    then
      printf ' %s' $no_users_msg
      hosts_free=$((hosts_free + 1))
      hfl="${hosts_free_list} ${n}"
      hosts_free_list=${hfl}
    else
      printf ' %s' $users
    fi
  fi

  printf ' \n'
  m=$((m - 1))
done


printf '\n'
printf '>---- ---- ---- ----\n'
printf ' %4s hosts in total checked.\n' ${#names[@]}
printf ' %4s hosts available.\n' $hosts_up
printf ' %4s hosts not available.\n' $hosts_down
printf ' %4s hosts have no users logged in.\n' $hosts_free
printf ' %s\n' $hosts_free_list
printf '>---- ---- ---- ----\n'

finish_time=$(date +%s)
printf '\nFinished in %s seconds.\n' $((finish_time - start_time))
