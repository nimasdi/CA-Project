SetActiveLib -work
comp -include "$dsn\src\controlunit.vhd" 
comp -include "$dsn\src\TestBench\controlunit_TB.vhd" 
asim +access +r TESTBENCH_FOR_controlunit 
wave 
wave -noreg clk_in
wave -noreg reset_in
wave -noreg alu_op_in
wave -noreg stage_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\controlunit_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_controlunit 
