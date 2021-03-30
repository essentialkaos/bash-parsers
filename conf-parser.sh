CONF_FILE=""
CONF_CACHE=""
CONF_CACHE_PATH=""
CONF_UPDATED=""

## CONF PARSING ################################################################

unset cu ch cc cn cl cg cm cv

CONF_FILE=${CONF_FILE//\~/$HOME}

if [[ -r $CONF_FILE ]] ; then
  [[ ! -d $CONF_CACHE_PATH || ! -w $CONF_CACHE_PATH ]] && unset CONF_CACHE

  cu=`whoami` ; ch=`md5sum $CONF_FILE | cut -f1 -d" "` ; cc="$CONF_CACHE_PATH/${cu}-${ch}"

  if [[ -n "$CONF_CACHE" && -f $cc && -r $cc ]] ; then
    source $cc
  else
    [[ -n "$CONF_CACHE" ]] && rm -f $CONF_CACHE_PATH/${cu}-* &> /dev/null && touch $cc && chmod 600 $cc

    while read cl ; do
      if [[ "${cl:0:1}" == "[" ]] ; then
        cg="${cl//]/}" ; cg="${cg//[/}" ; continue
      fi

      cm="${cl%:*}" ; cm="${cm// /}" ; cm="${cm//-/_}"
      cv=`echo $cl | cut -f2-99 -d":" | sed 's/^ //g' | tr -s " " | sed 's/,/ /g'`

      [[ "$cv" == "false" || -z "$cv" ]] && continue

      [[ -n "$CONF_CACHE" ]] && echo "${cg}_${cm}=\"${cv}\"" >> $cc || declare "${cg}_${cm}"="$cv"
    done < <(grep -Pv '^[ ]*(#(?!\!)|[ ]*$)|false[ ]*$' $CONF_FILE)

    [[ -n "$CONF_CACHE" ]] && source $cc && CONF_UPDATED=true
  fi
else
  showConfWarn 2> /dev/null || :
fi

unset cu ch cc cn cl cg cm cv

################################################################################