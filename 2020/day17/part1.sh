#!/usr/bin/env bash

contains() {
  local elem
  local match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

neighbours() {
  local neighbours=0
  local elem="$1"
  local cx;
  local cy;
  local cz;
  cx=$(echo "$elem" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\1/p')
  cy=$(echo "$elem" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\2/p')
  cz=$(echo "$elem" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\3/p')
  shift
  if contains "$((cx - 1)),$((cy - 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),$((cy - 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),$((cy - 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),${cy},$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),${cy},${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),${cy},$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),$((cy + 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),$((cy + 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx - 1)),$((cy + 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy - 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy - 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy - 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},${cy},$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},${cy},$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy + 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy + 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "${cx},$((cy + 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy - 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy - 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy - 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),${cy},$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),${cy},${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),${cy},$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy + 1)),$((cz - 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy + 1)),${cz}" "${@}"; then neighbours=$((neighbours+1)); fi
  if contains "$((cx + 1)),$((cy + 1)),$((cz + 1))" "${@}"; then neighbours=$((neighbours+1)); fi
  return $neighbours
}

min() {
  if [[ $1 -le $2 ]]; then
    printf "%d" $1
  else
    printf "%d" $2
  fi
}

max() {
  if [[ $1 -ge $2 ]]; then
    printf "%d" $1
  else
    printf "%d" $2
  fi
}

active=()

line=0
while read -r l; do
  column=0
  for (( i=0; i < ${#l}; i++ )); do
    if [[ ${l:$i:1} == "#" ]]; then
      active+=("${line},0,${column}")
    fi
    column=$((column+1))
  done
  line=$((line+1))
done

echo "This program may take a while. While it is running you may want to take a look at this: https://stackoverflow.com/questions/15974873/is-bash-very-slow"

for i in {1..6}; do
  newActive=("${active[@]}")
  minx=0
  maxx=0
  miny=0
  maxy=0
  minzig=0
  maxz=0
  for a in "${active[@]}"; do
    if [[ $a != "" ]]; then
      cx=$(echo "$a" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\1/p')
      cy=$(echo "$a" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\2/p')
      cz=$(echo "$a" | sed -rn 's/^([-0-9]{1,}),([-0-9]{1,}),([-0-9]{1,})$/\3/p')
      
      minx=$(min "$minx" "$cx")
      maxx=$(max "$maxx" "$cx")
      miny=$(min "$miny" "$cy")
      maxy=$(max "$maxy" "$cy")
      minzig=$(min "$minzig" "$cz")
      maxz=$(max "$maxz" "$cz")
      
      neighbours $a "${active[@]}"
      neighbours=$?
      if [[ $neighbours != 2 && $neighbours != 3 ]]; then
        newActive=("${newActive[@]/$a}")
      fi
    fi
  done
  
  minx=$((minx-1))
  maxx=$((maxx+1))
  miny=$((miny-1))
  maxy=$((maxy+1))
  minzig=$((minzig-1))
  maxz=$((maxz+1))
    
  echo "We have not forgotten you. Still working..."
  
  for (( x=$minx; x <= $maxx; x++ )); do
    for (( y=$miny; y <= $maxy; y++ )); do
      for (( z=$minzig; z <= $maxz; z++ )); do
        elem="${x},${y},${z}"
        if ! contains $elem "${active[@]}"; then
          neighbours $elem "${active[@]}"
          neighbours=$?
          if [[ $neighbours == 3 ]]; then
            if ! contains $elem "${newActive[@]}"; then
              newActive+=("${elem}")
            fi 
          fi
        fi
      done
    done
    echo "Please be patient..."
  done
  
  active=("${newActive[@]}")
done

count=0
for elem in "${active[@]}"; do
  if [[ $elem != "" ]]; then
    count=$((count+1))
  fi
done

echo -n "Here you go: "
echo $count