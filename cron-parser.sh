## CRON PARSER #################################################################

cronCurrentTime() {
  local cron_pt="$@"
  local date_pt=($(date "+%M %H %d %m %w" | sed 's/ 0/ /g'))

  cron_pt=(${cron_pt//"*"/!})

  local ok cn

  for cn in {0..4} ; do
    [[ $(cronPatternMatch "${cron_pt[cn]}" "${date_pt[cn]}") ]] && ok="${ok}1"
  done

  [[ "$ok" == "11111" ]] && echo 1 && return 0

  echo "" && return 1
}

cronPatternMatch() {
  local pattern="$1"
  local date="$2"

  [[ "$pattern" == "$date" ]] && echo 1 && return 0
  [[ "$pattern" == "!" ]] && echo 1 && return 0

  if [[ $pattern =~ "," ]] ; then
    [[ $date =~ ${pattern//,/|} ]] && echo 1 && return 0
  fi

  if [[ $pattern =~ "/" ]] ; then
    local prefix="${pattern%/*}"
    local postfix="${pattern#*/}"

    if [[ "$pattern" == "!" ]] ; then
      [[ $(echo "${date}%${postfix}" | bc) == "0" ]] && echo 1 && return 0
    elif [[ `echo "$prefix" | grep "-"` ]] ; then
      if [[ $date -ge ${prefix%-*} && $date -le ${prefix#*-} ]] ; then
        [[ $(echo "${date}%${postfix}" | bc) == "0" ]] && echo 1 && return 0
      fi
    fi
  fi

  if [[ $pattern =~ "-" ]] ; then
    [[ $date -ge ${pattern%-*} && $date -le ${pattern#*-} ]] && echo 1 && return 0
  fi

  echo "" && return 1
}

################################################################################