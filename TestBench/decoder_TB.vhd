library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity decoder_tb is
end decoder_tb;

architecture TB_ARCHITECTURE of decoder_tb is
	-- Component declaration of the tested unit
	component decoder
	port(
		clk_in : in STD_LOGIC;
		enable_in : in STD_LOGIC;
		instruction_in : in STD_LOGIC_VECTOR(15 downto 0);
		alu_op_out : out STD_LOGIC_VECTOR(4 downto 0);
		imm_data_out : out STD_LOGIC_VECTOR(7 downto 0);
		write_enable_out : out STD_LOGIC;
		sel_rM_out : out STD_LOGIC_VECTOR(2 downto 0);
		sel_rN_out : out STD_LOGIC_VECTOR(2 downto 0);
		sel_rD_out : out STD_LOGIC_VECTOR(2 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_in : STD_LOGIC;
	signal enable_in : STD_LOGIC;
	signal instruction_in : STD_LOGIC_VECTOR(15 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal alu_op_out : STD_LOGIC_VECTOR(4 downto 0);
	signal imm_data_out : STD_LOGIC_VECTOR(7 downto 0);
	signal write_enable_out : STD_LOGIC;
	signal sel_rM_out : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_rN_out : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_rD_out : STD_LOGIC_VECTOR(2 downto 0);

	-- Clock period definition
	constant clk_period : time := 10 ns;

begin

	-- Unit Under Test port map
	UUT : decoder
		port map (
			clk_in => clk_in,
			enable_in => enable_in,
			instruction_in => instruction_in,
			alu_op_out => alu_op_out,
			imm_data_out => imm_data_out,
			write_enable_out => write_enable_out,
			sel_rM_out => sel_rM_out,
			sel_rN_out => sel_rN_out,
			sel_rD_out => sel_rD_out
		);

	-- Clock generation process
	clk_process: process
	begin
		clk_in <= '0';
		wait for clk_period / 2;
		clk_in <= '1';
		wait for clk_period / 2;
	end process;

	-- Stimulus process
	stim_proc: process
	begin
		-- Initialize inputs
		enable_in <= '0';
		instruction_in <= (others => '0');
		wait for clk_period;

		-- Enable the decoder
		enable_in <= '1';

		-- Test case 1: ADD instruction (RRR type)
		instruction_in <= "00000" & "001" & "010" & "011" & "00"; -- ADD r1, r2, r3
		wait for clk_period;
		assert alu_op_out = "00000" report "Test case 1: ALU op incorrect for ADD" severity error;
		assert sel_rD_out = "001" report "Test case 1: rD select incorrect for ADD" severity error;
		assert sel_rM_out = "010" report "Test case 1: rM select incorrect for ADD" severity error;
		assert sel_rN_out = "011" report "Test case 1: rN select incorrect for ADD" severity error;
		assert write_enable_out = '1' report "Test case 1: Write enable incorrect for ADD" severity error;

		-- Test case 2: IMMEDIATE instruction (RI type)
		instruction_in <= "01011" & "100" & "10101010"; -- IMMEDIATE r4, 0xAA
		wait for clk_period;
		assert alu_op_out = "01011" report "Test case 2: ALU op incorrect for IMMEDIATE" severity error;
		assert sel_rD_out = "100" report "Test case 2: rD select incorrect for IMMEDIATE" severity error;
		assert imm_data_out = "10101010" report "Test case 2: Immediate data incorrect for IMMEDIATE" severity error;
		assert write_enable_out = '1' report "Test case 2: Write enable incorrect for IMMEDIATE" severity error;

		-- Test case 3: B instruction (UI type)
		instruction_in <= "01001" & "000" & "11111111"; -- B 0xFF
		wait for clk_period;
		assert alu_op_out = "01001" report "Test case 3: ALU op incorrect for B" severity error;
		assert imm_data_out = "11111111" report "Test case 3: Immediate data incorrect for B" severity error;
		assert write_enable_out = '0' report "Test case 3: Write enable incorrect for B" severity error;

		-- Test case 4: ST instruction (URR type)
		instruction_in <= "01101" & "000" & "110" & "101" & "00"; -- ST r6, r5
		wait for clk_period;
		assert alu_op_out = "01101" report "Test case 4: ALU op incorrect for ST" severity error;
		assert sel_rM_out = "110" report "Test case 4: rM select incorrect for ST" severity error;
		assert sel_rN_out = "101" report "Test case 4: rN select incorrect for ST" severity error;
		assert write_enable_out = '0' report "Test case 4: Write enable incorrect for ST" severity error;

		-- Test case 5: LSL instruction (RRI type)
		instruction_in <= "00110" & "010" & "010" & "011" & "00"; -- LSL r2, r2, r3
		wait for clk_period;
		assert alu_op_out = "00110" report "Test case 5: ALU op incorrect for LSL" severity error;
		assert sel_rD_out = "010" report "Test case 5: rD select incorrect for LSL" severity error;
		assert sel_rM_out = "010" report "Test case 5: rM select incorrect for LSL" severity error;
		assert sel_rN_out = "011" report "Test case 5: rN select incorrect for LSL" severity error;
		assert imm_data_out = "01001100" report "Test case 5: Immediate data incorrect for LSL" severity error;
		assert write_enable_out = '1' report "Test case 5: Write enable incorrect for LSL" severity error;

		-- End of simulation
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_decoder of decoder_tb is
	for TB_ARCHITECTURE
		for UUT : decoder
			use entity work.decoder(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_decoder;