# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Clock_divider" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Device" -parent ${Page_0}


}

proc update_PARAM_VALUE.Clock_divider { PARAM_VALUE.Clock_divider } {
	# Procedure called to update Clock_divider when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Clock_divider { PARAM_VALUE.Clock_divider } {
	# Procedure called to validate Clock_divider
	return true
}

proc update_PARAM_VALUE.Device { PARAM_VALUE.Device } {
	# Procedure called to update Device when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Device { PARAM_VALUE.Device } {
	# Procedure called to validate Device
	return true
}


proc update_MODELPARAM_VALUE.Device { MODELPARAM_VALUE.Device PARAM_VALUE.Device } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Device}] ${MODELPARAM_VALUE.Device}
}

proc update_MODELPARAM_VALUE.Clock_divider { MODELPARAM_VALUE.Clock_divider PARAM_VALUE.Clock_divider } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Clock_divider}] ${MODELPARAM_VALUE.Clock_divider}
}

