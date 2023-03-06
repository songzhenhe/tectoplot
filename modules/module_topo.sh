TECTOPLOT_MODULES+=("topo")

# function tectoplot_defaults_topo() {
# }

function tectoplot_args_topo()  {
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  case "${1}" in

  -tcycle)
  tectoplot_get_opts_inline '
des -tcycle Add cyclicity saturation to topography color stretch
opn num tcyclecptnum float 10
  number of saturation cycles
opn low tcycle_cptlow float 0
  low cut for input saturation CPT
opn high tcycle_cpthigh float 0.5
  high cut for input saturation CPT
opn cpt tcyclecptcpt cpt gray
  CPT used to generate cyclic saturation
opn step tcyclestepval float 1000
  step used in generating cycle
opn method tcyclemethod string average
  method used to comine CPTs (average, multiply)
' "${@}" || return

  tcyclecptflag=1
  ;;

esac
}
