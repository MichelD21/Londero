# Last update: 2016/07/05

#-----------------------------------------------------------------------------
# General Comments
#-----------------------------------------------------------------------------
puts "  "
puts "  "
puts "  "
puts "  "

#-----------------------------------------------------------------------------
# Main Custom Variables Design Dependent (set local)
#-----------------------------------------------------------------------------
set CLK_S $env(CLK_S)
set RST_S $env(RST_S)
set PROJECT_DIR $env(PROJECT_DIR)
set TECH_DIR $env(TECH_DIR)
set VERILOGS $env(VERILOGS)
set DESIGNS $env(DESIGNS)
set HDL_NAME $env(HDL_NAME)
set CLK_PERIOD $env(CLK_PERIOD)
set CLK_FREQ $env(CLK_FREQ)
set INTERCONNECT_MODE ple

set MAIN_CLOCK_NAME ${CLK_S}
set MAIN_RST_NAME ${RST_S}
set OPERATING_CONDITIONS PwcV162T125_STD_CELL_7RF
set period_clk ${CLK_PERIOD}  ;#clk = 10.00MHz = 100ns (period) ;#clk = 10.00MHz = 100ns (period)
set clk_uncertainty 0.25 ;# ns (“a guess”)
set clk_latency 0.35 ;# ns (“a guess”)
set in_delay 0.1 ;# ns
set out_delay 0.3 ;#ns BC1820PU_PM_A (1.518 + 0.032xCL) = (1.518 + 0.032x45 fF)
set out_load 0.045 ;#pF (15 fF + 30 fF) = pin A of IO Cell BC1820PU_PM_A (15 fF) + “a guess”
set slew "146 164 264 252" ;#minimum rise, minimum fall, maximum rise and maximum fall - pin Z of IO Cell BC1820PU_PM_A
set slew_min_rise 0.146 ;# ns
set slew_min_fall 0.164 ;# ns
set slew_max_rise 0.264 ;# ns
set slew_max_fall 0.252 ;# ns

set WORST_LIST {PwcV162T125_STD_CELL_7RF.lib}
set LEF_LIST {cmos7rf_6ML_tech.lef ibm_cmos7rf_sc_12Track.lef}

source ${PROJECT_DIR}/trunk/backend/synthesis/scripts/common/path.tcl

source ${SCRIPT_DIR}/common/tech.tcl

set_attribute hdl_search_path "${DEV_DIR} ${FRONTEND_DIR}"
if {${VERILOGS} ne " "} {
	read_hdl ${VERILOGS}
}
if {${DESIGNS} ne " "} {
	read_hdl -vhdl ${DESIGNS}
}


elaborate ${HDL_NAME}

synthesize -to_gen ${HDL_NAME} ;# timing driven CSA optimization

read_sdc ${BACKEND_DIR}/synthesis/constraints/constraints.sdc
set_attribute fixed_slew ${slew} /designs/${HDL_NAME}/ports_in/*

synthesize -to_map ${HDL_NAME} ;# timing driven CSA optimization

report design_rules > ${BACKEND_DIR}/synthesis/reports/${HDL_NAME}_${CLK_FREQ}Mhz_drc.rpt
report area > ${BACKEND_DIR}/synthesis/reports/${HDL_NAME}_${CLK_FREQ}Mhz_area.rpt
report timing > ${BACKEND_DIR}/synthesis/reports/${HDL_NAME}_${CLK_FREQ}Mhz_timing.rpt
report gates > ${BACKEND_DIR}/synthesis/reports/${HDL_NAME}_${CLK_FREQ}Mhz_gates.rpt
report power > ${BACKEND_DIR}/synthesis/reports/${HDL_NAME}_${CLK_FREQ}Mhz_power.rpt
write_sdf -edge check_edge -nonegchecks -setuphold split -version 2.1 -design ${HDL_NAME} > ${DEV_DIR}/${HDL_NAME}_${CLK_FREQ}Mhz.sdf
write_hdl ${HDL_NAME} > ${DEV_DIR}/${HDL_NAME}_${CLK_FREQ}Mhz.v

#exit

