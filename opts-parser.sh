SUPPORTED_OPTS=""
SHORT_OPTS=""
MERGEABLE_OPTS=""
KEEP_OPTS=true

## OPTIONS PARSING 6 ###########################################################

if [[ $# -eq 0 ]] ; then
  main
  exit $?
fi

unset opt optn optm optv optt optk

optv="$*" ; optt=()

while [[ -n "$1" ]] ; do
  if [[ "$1" =~ \  && -n "$optn" ]] ; then
    declare "$optn=$1"

    unset optn && shift && continue
  elif [[ $1 =~ ^-{1}[a-zA-Z0-9]{1,2}+.*$ ]] ; then
    optm=${1:1}

    if [[ \ $SHORT_OPTS\  =~ \ $optm:!?([a-zA-Z0-9_]*) ]] ; then
      opt="${BASH_REMATCH[1]}"
    else
      declare -F showOptWarn &>/dev/null && showOptWarn "-$optm"
      shift && continue
    fi

    if [[ -z "$optn" ]] ; then
      optn=$opt
    else
      # shellcheck disable=SC2015
      [[ -z "$optk" ]] && ( declare -F showOptValWarn &>/dev/null && showOptValWarn "--$optn" ) || declare "$optn=true"
      optn=$opt
    fi

    if [[ ! $SUPPORTED_OPTS\  =~ !?$optn\  ]] ; then
      declare -F showOptWarn &>/dev/null && showOptWarn "-$optm"
      shift && continue
    fi

    if [[ ${BASH_REMATCH[0]:0:1} == "!" ]] ; then
      declare "$optn=true" ; unset optn ; optk=true
    else
      unset optk
    fi

    shift && continue
  elif [[ "$1" =~ ^-{2}[a-zA-Z]{1}[a-zA-Z0-9_-]+.*$ ]] ; then
    opt=${1:2}

    if [[ $opt == *=* ]] ; then
      IFS="=" read -ra opt <<< "$opt"

      optm="${opt[0]}" ; optm=${optm//-/_}

      if [[ ! $SUPPORTED_OPTS\  =~ $optm\  ]] ; then
        declare -F showOptWarn &>/dev/null && showOptWarn "--${opt[0]//_/-}"
        shift && continue
      fi

      # shellcheck disable=SC2015
      [[ -n "${!optm}" && $MERGEABLE_OPTS\  =~ $optm\  ]] && declare "$optm=${!optm} ${opt[*]:1:99}" || declare "$optm=${opt[*]:1:99}"

      unset optm && shift && continue
    else
      # shellcheck disable=SC2178
      opt=${opt//-/_}

      if [[ -z "$optn" ]] ; then
        # shellcheck disable=SC2128
        optn=$opt
      else
        # shellcheck disable=SC2015
        [[ -z "$optk" ]] && ( declare -F showOptValWarn &>/dev/null && showOptValWarn "--$optn" ) || declare "$optn=true"
        # shellcheck disable=SC2128
        optn=$opt
      fi

      if [[ ! $SUPPORTED_OPTS\  =~ !?$optn\  ]] ; then
        declare -F showOptWarn &>/dev/null && showOptWarn "--${optn//_/-}"
        shift && continue
      fi

      if [[ ${BASH_REMATCH[0]:0:1} == "!" ]] ; then
        declare "$optn=true" ; unset optn ; optk=true
      else
        unset optk
      fi

      shift && continue
    fi
  else
    if [[ -n "$optn" ]] ; then
      # shellcheck disable=SC2015
      [[ -n "${!optn}" && $MERGEABLE_OPTS\  =~ $optn\  ]] && declare "$optn=${!optn} $1" || declare "$optn=$1"

      unset optn && shift && continue
    fi
  fi

  optt+=("$1") ; shift
done

[[ -n "$optn" ]] && declare "$optn=true"

unset opt optn optm optk

# shellcheck disable=SC2015,SC2086
[[ -n "$KEEP_OPTS" ]] && main $optv || main "${optt[@]}"

################################################################################
