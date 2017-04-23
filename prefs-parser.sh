SUPPORTED_ARGS=""
PREFS_FILE=""

## PREFS PARSING ##############################################################

unset arg argn argp

PREFS_FILE=${PREFS_FILE//\~/$HOME}

if [[ -n "$PREFS_FILE" && -r $PREFS_FILE ]] ; then
  while read arg ; do
    IFS=":" read argn argp <<< "${arg//: /:}"
    argn="${argn//-/_}"
    [[ $SUPPORTED_ARGS\  =~ !?$argn\  ]] && declare $argn="$argp"
  done < <(grep -Pv '^[ ]*(#(?!\!)|[ ]*$)' $PREFS_FILE)

  unset arg argn argp
fi

###############################################################################
