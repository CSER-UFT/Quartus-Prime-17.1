# compile.tcl — roda com: quartus_sh -t compile.tcl
package require ::quartus::project
package require ::quartus::flow

set project_name "and_gate"

project_new $project_name -overwrite

set_global_assignment -name FAMILY "Cyclone II"
set_global_assignment -name DEVICE EP2C20F484C7
set_global_assignment -name VHDL_FILE and_gate.vhd
set_global_assignment -name TOP_LEVEL_ENTITY and_gate

set_location_assignment PIN_L22 -to SW0
set_location_assignment PIN_L21 -to SW1
set_location_assignment PIN_R20 -to LEDR0

export_assignments
execute_flow -compile

project_close
