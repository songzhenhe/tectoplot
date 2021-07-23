# gmt_module_interface.sh
# Source this file

# In an attempt to support old GMT versions and protect against future changes to GMT, these
# wrapper functions translate inputs and parameters into GMT calls for different versions/modules
# that have had significant recent changes in GMT syntax

# gmt psmeca -E"${CMT_SSCOLOR}" -C$SEIS_CPT ${CMTEXTRA} ${CMT_INPUTORDER} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_STRIKESLIPPLOT} -L${FMLPEN} $RJOK $VERBOSE >> map.ps

# assumes $RJOK $VERBOSE for all calls

# psmeca between v6.1 and v6.2 saw some changes (-Z -> -C)
# gmt_psmeca CPT_FILE options...

function gmt_version() {
  gawk -v vers=${GMTVERSION} '
  BEGIN {
    if (vers >= "6.2.0") {
      if (vers > "6.2.0") {
        print "newer_6.2"
      } else {
        print 6.2
      }
    } else {
      print "older"
    }
  }'
}

# < 6.2 : -Z for colors; >= 6.2 : -C for same effect
# usage:
# gmt_psmeca CPT_FILE {All options other than -Z/-C}

function gmt_psmeca() {
  local CPT_FILE="${1}"
  shift

  case $(gmt_version) in
    6.2|newer_6.2)
      gmt psmeca -C${CPT_FILE} ${@}
      ;;
    older)
      gmt psmeca -Z${CPT_FILE} ${@}
      ;;
    *)
      echo "unknown"
      ;;
  esac
}
