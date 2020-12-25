# Simple constraints file - April 2019 - Ioannis Karageorgos ioannis.karageorgos@yale.edu

set sdc_version 2.0

set_units -capacitance 1.0fF
set_units -time 1.0ps
# set_units -resistance 1.0??  -  Not supported yet but maybe in future versions

# ## Create clock(s) ##
    #CLK PERIOD in ps:
        set CLK_PERIOD [expr double(1)/*1000000]

    #Pulse width (assuming 50% duty cycle)
        set PW [expr /2]

    create_clock [get_ports ] -name 
main_clk -period  -waveform [list 0 [expr ]]


# Set the maximum transition time => max transition time = clock period * (AF*DF); get these values from the PDK; units are fF and ps
# To be on the safe side put 2/3 of the max transition calculation
#set_db design: .max_transition xxx
set_max_transition 200 [current_design]
set_load -pin_load 10 [all_outputs]

# Set the resistance of extrenal driver in KOhms
set_drive 0.5 [all_inputs]

# Set the driving cell ##
set_driving_cell -cell  -from_pin A [all_inputs]

# Set input transition value if no driving cell is used
# set_input_transition 20 [all_inputs]

# Set the delay from the primary inputs / outputs (use something close to the pads delay)
# input delay is the time it takes for the inputs to become stable wrt clock
# output delay is the time it takes for the outputs to become stable wrt clock
set_input_delay -add_delay 5 [all_inputs] -clock main_clk -min
set_input_delay -add_delay 20 [all_inputs] -clock main_clk -max
set_output_delay -add_delay 5 [all_outputs] -clock main_clk -min
set_output_delay -add_delay 20 [all_outputs] -clock main_clk -max


set_clock_uncertainty 14 main_clk
set_clock_latency 10 main_clk -source -early
set_clock_latency 20 main_clk -source -late

set_false_path -from 
