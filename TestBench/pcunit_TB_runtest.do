SetActiveLib -work
comp -include "$dsn\src\pc.vhd" 
comp -include "$dsn\src\TestBench\pcunit_TB.vhd" 
asim +access +r TESTBENCH_FOR_pcunit 
wave 
wave -noreg clk_in
wave -noreg pc_op_in
wave -noreg pc_in
wave -noreg pc_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\pcunit_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_pcunit 
