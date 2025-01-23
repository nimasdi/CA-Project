SetActiveLib -work
comp -include "$dsn\src\decoder.vhd" 
comp -include "$dsn\src\TestBench\decoder_TB.vhd" 
asim +access +r TESTBENCH_FOR_decoder 
wave 
wave -noreg clk_in
wave -noreg enable_in
wave -noreg instruction_in
wave -noreg alu_op_out
wave -noreg imm_data_out
wave -noreg write_enable_out
wave -noreg sel_rM_out
wave -noreg sel_rN_out
wave -noreg sel_rD_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\decoder_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_decoder 
