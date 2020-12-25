#!/usr/bin/env tclsh
# Logic synthesis script for Genus (single clock) - April 2019 - Ioannis Karageorgos ioannis.karageorgos@yale.edu

set_db / .max_cpus_per_server 16
set_db / .super_thread_servers {localhost localhost localhost localhost localhost localhost localhost localhost localhost localhost localhost localhost}
set_db / .auto_super_thread true

proc pause {{message "Hit Enter to continue ==> "}} {
    puts -nonewline $message
    flush stdout
    gets stdin
}

# ############################  USER INPUTS  ############################
# #######################################################################
# Set target frequency in MHz:
    set FRQ 800

# ### Note => when creating lists and separating elements with new lines: end each line with an extra space character

# Set the paths to your library files; in this section we are setting timing-power liberty, .LEF, and tech lef:
    set LIB_PATH {
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_CORE_LR/3.2-00/libs
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_CLK_LR/3.2-00/libs
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_PR_LR/3.2-00/libs
    }

    set LIBLEF_PATH {
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_CORE_LR/3.2-00/CADENCE/LEF
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_CLK_LR/3.2-00/CADENCE/LEF
        /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/C28SOI_SC_12_PR_LR/3.2-00/CADENCE/LEF
    }

    set TECHLEF_PATH /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/CadenceTechnoKit_cmos028FDSOI_6U1x_2U2x_2T8x_LB_LowPower/4.2-00/LEF

# Set the file names of the libraries here:
    set LIB_TIMING_SETUP_FILENAME {
        C28SOI_SC_12_CORE_LR_ss28_0.80V_125C.lib
        C28SOI_SC_12_CLK_LR_ss28_0.80V_125C.lib
        C28SOI_SC_12_PR_LR_ss28_0.80V_125C.lib
    }
    set LIB_TIMING_HOLD_FILENAME {
        C28SOI_SC_12_CORE_LR_ff28_1.00V_m40C.lib
        C28SOI_SC_12_CLK_LR_ff28_1.00V_m40C.lib
        C28SOI_SC_12_PR_LR_ff28_1.00V_m40C.lib
    }

    set LIB_TYP_POWER_FILENAME {
        C28SOI_SC_12_CORE_LR_tt28_0.90V_25C.lib
        C28SOI_SC_12_CLK_LR_tt28_0.90V_25C.lib
        C28SOI_SC_12_PR_LR_tt28_0.90V_25C.lib
    }
    set LIB_MAX_POWER_FILENAME {
        C28SOI_SC_12_CORE_LR_ff28_1.00V_125C.lib
        C28SOI_SC_12_CLK_LR_ff28_1.00V_125C.lib
        C28SOI_SC_12_PR_LR_ff28_1.00V_125C.lib
    }

    set PnR_LIB_NAME C28SOI_SC_12_PR_LR
    set LIBLEF_FILENAME {
        C28SOI_SC_12_CORE_LR_soc.lef
        C28SOI_SC_12_CLK_LR_soc.lef
        C28SOI_SC_12_PR_LR_soc.lef
    }
    set TECHLEF_FILENAME technology.12T.lef

# Set path and filenames of the qrc files
    set QRC_PATH /SAY/standard/rm2267-654001-SEAS/tech/ST/ST_28SOI/CadenceTechnoKit_cmos028FDSOI_6U1x_2U2x_2T8x_LB_LowPower/4.2-00/QRC_TECHFILE
    set QRC_RCTYP_FILENAME $QRC_PATH/nominal.tech
    set QRC_CMIN_FILENAME $QRC_PATH/FuncCmin.tech
    set QRC_RCMIN_FILENAME $QRC_PATH/FuncRCmin.tech
    set QRC_CMAX_FILENAME $QRC_PATH/FuncCmax.tech
    set QRC_RCMAX_FILENAME $QRC_PATH/FuncRCmax.tech

# Set name of NAND2_X1 gate (for area GE estimate)
    set NAND2_X1_NAME C12T28SOI_LR_NAND2X3_P0

# Set the name of the driving cell:
    set DRV_CELL_NAME "C12T28SOI_LR_IVX4_P0"

# Set the names of the tie-high tie-low cells:
    set TIEHI_CELL "C12T28SOI_LR_TOHX8"
    set TIELO_CELL "C12T28SOI_LR_TOLX8"

# Set a user-friendly alias name for the technology
    set TECH_FRIENDLY_NAME ST_28nm_FDSOI

# Set the HDL design location:
    set HDL_PATH {/home/fas/manohar/ks2446/project/RTL/RISCV/core}

# Set the HDL file list, top level design and clock name
# If no HDL files are used for one or more of the languages use: set FILE_LISTxxx {}
    # Verilog files
    set HDL_FILENAME {}

    # SystemVerilog files
    set HDL_FILENAME_sv {
        wrapper_CORE.v
        ibex_defines.sv
        ibex_alu.sv
        ibex_compressed_decoder.sv
        ibex_controller.sv
        ibex_core.sv
        ibex_cs_registers.sv
        ibex_decoder.sv
        ibex_ex_block.sv
        ibex_fetch_fifo.sv
        ibex_id_stage.sv
        ibex_if_stage.sv
        ibex_int_controller.sv
        ibex_load_store_unit.sv
        ibex_multdiv_fast.sv
        ibex_multdiv_slow.sv
        ibex_prefetch_buffer.sv
        ibex_register_file.sv
        prim_clock_gating.sv
    }

    # VHDL files
    set HDL_FILENAME_vhdl {}

    # Top level module name
    set TOP wrapper_CORE

    # Clock name
    set CLOCKNAME clk_i

    # Reset name
    set RSTNAME rst_ni

# #######################################################################
# #######################################################################


# Copy source HDL files
    set TMP_HDL_LIST [glob $HDL_PATH/*]
    file mkdir source_HDL_files
    file copy {*}$TMP_HDL_LIST source_HDL_files

# Set names for the library domains
    set LIB_DOMAIN_SS ss_Vddx0.9_125C

create_library_domain $LIB_DOMAIN_SS
set_db init_lib_search_path "$LIB_PATH $LIBLEF_PATH $TECHLEF_PATH"
set_db init_hdl_search_path "$HDL_PATH"
# Reading library files can create a lot of stdout clutter (in many cases hundreds of pages). In initial run remove the "redirect ..." part
# to check if everything is OK with respect to all the received warnings ("redirect" command suppresses all warnings). Once you verify that
# everything is OK, use the redirect command to have a cleaner output.
#set_db library_domain:$LIB_DOMAIN_SS .library $LIB_TIMING_SETUP_FILENAME
#set_db / .lef_library "$TECHLEF_FILENAME $LIBLEF_FILENAME"
redirect parse_LIB_SS.log { set_db library_domain:$LIB_DOMAIN_SS .library $LIB_TIMING_SETUP_FILENAME }
redirect parse_LEF.log { set_db / .lef_library "$TECHLEF_FILENAME $LIBLEF_FILENAME" }

set_db map_timing true
set_db ultra_global_mapping true
set_db auto_partition true
# adjust as necessary to see less/more details
#set_db information_level


    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Read HDL--------------------------------------\n\n"
# ## Read HDL files ##
    if {$HDL_FILENAME ne ""} {
        read_hdl $HDL_FILENAME -v2001
    }
    if {$HDL_FILENAME_sv ne ""} {
        read_hdl $HDL_FILENAME_sv -sv
    }
    if {$HDL_FILENAME_vhdl ne ""} {
        read_hdl $HDL_FILENAME_vhdl -vhdl
    }
    puts "\n\n--------------------------------------End read HDL--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"


# ## TOOL OPTIONS ###
    #set_db lp_insert_clock_gating true
    #set_db lp_clock_gating_prefix CLKgating
    set_db / .lp_power_analysis_effort high
    set_db / .retime_reg_naming_suffix "RETimed"

# ## ELABORATE ###
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Elaborating design--------------------------------------\n\n"
    elaborate
    check_design
    check_design -unresolved
    puts "\n\n--------------------------------------End elaborating design--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"

# Set units
    set_units -time ps
    set_units -capacitance fF
    set_load_unit -femtofarads
    #set_units -power uW

# Set wire load pessimism
    set soceSupportWireLoadMode 1
#    set_wire_load_model -name Huge
    set_wire_load_model -name auto_select



# ## Multi-corner analysis and constraints ##
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Setting MMMC and constraints--------------------------------------\n\n"
    create_library_set -name LIB_SET_TIMING_SETUP -timing $LIB_TIMING_SETUP_FILENAME
    create_library_set -name LIB_SET_TIMING_HOLD -timing $LIB_TIMING_HOLD_FILENAME
    create_library_set -name LIB_SET_TYP_POWER -timing $LIB_TYP_POWER_FILENAME
    create_library_set -name LIB_SET_MAX_POWER -timing $LIB_MAX_POWER_FILENAME
    create_constraint_mode -name CONSTRAINT_MODE_1 -sdc_files {../source_files/constraints.sdc}
    create_timing_condition -name TIMING_COND_SETUP -library_sets LIB_SET_TIMING_SETUP
    create_timing_condition -name TIMING_COND_HOLD -library_sets LIB_SET_TIMING_HOLD
    create_timing_condition -name TIMING_COND_TYP_POWER -library_sets LIB_SET_TYP_POWER
    create_timing_condition -name TIMING_COND_MAX_POWER -library_sets LIB_SET_MAX_POWER

    create_rc_corner -name RC_CORNER_RCTYP_T25 -temperature 25 -qrc_tech $QRC_RCTYP_FILENAME
    create_rc_corner -name RC_CORNER_CMIN_T125 -temperature 125 -qrc_tech $QRC_CMIN_FILENAME
    create_rc_corner -name RC_CORNER_RCMIN_T125 -temperature 125 -qrc_tech $QRC_RCMIN_FILENAME
    create_rc_corner -name RC_CORNER_CMAX_T125 -temperature 125 -qrc_tech $QRC_CMAX_FILENAME
    create_rc_corner -name RC_CORNER_RCMAX_T125 -temperature 125 -qrc_tech $QRC_RCMAX_FILENAME
    create_rc_corner -name RC_CORNER_CMIN_Tm40 -temperature -40 -qrc_tech $QRC_CMIN_FILENAME
    create_rc_corner -name RC_CORNER_RCMIN_Tm40 -temperature -40 -qrc_tech $QRC_RCMIN_FILENAME
    create_rc_corner -name RC_CORNER_CMAX_Tm40 -temperature -40 -qrc_tech $QRC_CMAX_FILENAME
    create_rc_corner -name RC_CORNER_RCMAX_Tm40 -temperature -40 -qrc_tech $QRC_RCMAX_FILENAME

    create_delay_corner -name CORNER_TIMING_SETUP -timing_condition TIMING_COND_SETUP -rc_corner RC_CORNER_RCMAX_T125
    create_delay_corner -name CORNER_TIMING_HOLD -timing_condition TIMING_COND_HOLD -rc_corner RC_CORNER_RCMIN_Tm40
    create_delay_corner -name CORNER_TYP_POWER_RCTYP_T25 -timing_condition TIMING_COND_TYP_POWER -rc_corner RC_CORNER_RCTYP_T25
    create_delay_corner -name CORNER_MAX_POWER_RCMIN_T125 -timing_condition TIMING_COND_MAX_POWER -rc_corner RC_CORNER_RCMIN_T125

    create_analysis_view -name ANALYSIS_VIEW_TIMING_SETUP -constraint_mode CONSTRAINT_MODE_1 -delay_corner CORNER_TIMING_SETUP
    create_analysis_view -name ANALYSIS_VIEW_TIMING_HOLD -constraint_mode CONSTRAINT_MODE_1 -delay_corner CORNER_TIMING_HOLD
    create_analysis_view -name ANALYSIS_VIEW_TYP_POWER_RCTYP_T25 -constraint_mode CONSTRAINT_MODE_1 -delay_corner CORNER_TYP_POWER_RCTYP_T25
    create_analysis_view -name ANALYSIS_VIEW_MAX_POWER_RCMIN_T125 -constraint_mode CONSTRAINT_MODE_1 -delay_corner CORNER_MAX_POWER_RCMIN_T125

    set_analysis_view -setup { \
        ANALYSIS_VIEW_TIMING_SETUP \
        ANALYSIS_VIEW_TIMING_HOLD \
        ANALYSIS_VIEW_TYP_POWER_RCTYP_T25 \
        ANALYSIS_VIEW_MAX_POWER_RCMIN_T125 \
        } -hold { \
        ANALYSIS_VIEW_TIMING_HOLD \
        ANALYSIS_VIEW_TYP_POWER_RCTYP_T25 \
        ANALYSIS_VIEW_MAX_POWER_RCMIN_T125 \
        } -leakage ANALYSIS_VIEW_MAX_POWER_RCMIN_T125 -dynamic ANALYSIS_VIEW_MAX_POWER_RCMIN_T125

    init_design
    puts "\n\n--------------------------------------End setting MMMC and constraints--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"

# Can only retime after design is elaborated (but before synthesis)
    # power increase; set to false
    set_db "design:$TOP" .retime false

    set_db port:$TOP/fetch_enable_i .lp_asserted_probability 1
    set_db port:$TOP/rst_ni .lp_asserted_probability 1

    set_db leakage_power_effort medium

# ********************************
# ** SYNTHESIS TO GENERIC GATES **
# ********************************
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Synthesis--------------------------------------\n\n"
    set_db syn_generic_effort medium
    syn_generic
    puts "\n\n--------------------------------------End synthesis--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"
# ********************************

write_reports -directory reports -tag synth_

# ***************************
# ** MAPPING TO TECHNOLOGY **
# ***************************
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Mapping--------------------------------------\n\n"
    set_db syn_map_effort medium
    syn_map
    puts "\n\n--------------------------------------End mapping--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"
# ***************************

write_reports -directory reports -tag map_

# ******************
# ** OPTIMIZATION **
# ******************
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Optimization--------------------------------------\n\n"
    # high effort is the default, however it will increase execution time significantly
    set_db syn_opt_effort high
    syn_opt
    puts "\n\n--------------------------------------End optimization--------------------------------------\n\n\n\n\n\n\n\n\n\n\n\n"
# ******************


# ## add tie cells ##
    # auto:
    #    add_tieoffs -max_fanout 4 -verbose
    # specify:
        add_tieoffs -high lib_cell:LIB_SET_TIMING_SETUP/$PnR_LIB_NAME/$TIEHI_CELL -low lib_cell:LIB_SET_TIMING_SETUP/$PnR_LIB_NAME/$TIELO_CELL -max_fanout 4 -verbose


# ## Reports ##
    puts "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n--------------------------------------Reporting--------------------------------------\n\n"
    write_reports -directory reports -tag final_

#    set FRQ [expr int( 1000000 * double(1)/$CLK_PERIOD)]
    puts "\n\nFrequency(MHz): ${FRQ}\n\n"

    report_gates
    report_gates -power
    report_timing
    report_area
    report_area -normalize_with_gate $NAND2_X1_NAME
    puts "\n\nPower analysis WITHOUT switching activity information:\n"
    report_power -view ANALYSIS_VIEW_TYP_POWER_RCTYP_T25
    report_power -view ANALYSIS_VIEW_MAX_POWER_RCMIN_T125

# ## Write synthesized netlist ##
    write_hdl -language v2001 > ${TOP}_synthesized_${TECH_FRIENDLY_NAME}__${FRQ}MHz.v

pause

# ## Read switching activity information (if exists) ##
    if {[file exists ./saif.txt] == 1} {
        #file copy ../source_files/saif.txt .
        #file delete ../source_files/saif.txt
        puts "\n\nPower analysis WITH switching activity information:\n"
        read_saif -instance DUT ./saif.txt
        report_power -view ANALYSIS_VIEW_TYP_POWER_RCTYP_T25
        report_power -view ANALYSIS_VIEW_MAX_POWER_RCMIN_T125
    }

exit
