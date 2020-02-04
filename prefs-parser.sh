SUPPORTED_ARGS=""
PREFS_FILE=""

## PREFS PARSING ##############################################################

unset arg argn argp

PREFS_FILE=${PREFS_FILE//\~/$HOME}

if [[ -n "$PREFS_FILE" && -r "$PREFS_FILE" ]] ; then
  while read -r arg ; do
    [[ "$arg" =~ ^\# ]] && continue
    arg="${arg/: /:}" ; argn="${arg%:*}" ; argn="${argn//-/_}" ; argp="${arg#*:}"
    [[ "$SUPPORTED_ARGS " =~ $argn\  ]] && declare "$argn=$argp"
  done < <(awk 1 "$PREFS_FILE")

  unset arg argn argp
fi

###############################################################################
