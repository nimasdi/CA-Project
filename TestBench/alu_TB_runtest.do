SetActiveLib -work
comp -include "$dsn\src\alu.vhd" 
comp -include "$dsn\src\TestBench\alu_TB.vhd" 
asim +access +r TESTBENCH_FOR_alu 
wave 
wave -noreg clk_in
wave -noreg enable_in
wave -noreg alu_op_in
wave -noreg pc_in
wave -noreg rM_data_in
wave -noreg rN_data_in
wave -noreg imm_data_in
wave -noreg result_out
wave -noreg branch_out
wave -noreg rD_write_enable_in
wave -noreg rD_write_enable_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\alu_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_alu 
