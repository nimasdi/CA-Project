library IEEE;
use IEEE.STD_LOGIC_1164.all;  
use IEEE.NUMERIC_STD.all;


entity decoder is
	Port ( clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            instruction_in : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_out : out STD_LOGIC_VECTOR (4 downto 0);
            imm_data_out : out STD_LOGIC_VECTOR (7 downto 0); 
            write_enable_out : out STD_LOGIC;
            sel_rM_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_out : out STD_LOGIC_VECTOR (2 downto 0));
end decoder;

architecture Behavioral of decoder is
begin
	process(clk_in)
	begin
		if(rising_edge(clk_in) and enable_in='1') then
			alu_op_out <= instruction_in(15 downto 11);
			sel_rD_out <= instruction_in(10 downto 8);
			sel_rM_out <= instruction_in(7 downto 5);
			sel_rN_out <= instruction_in(4 downto 2);
			
			if alu_op_out = "0110" or alu_op_out = "0111" then
				imm_data_out <= instruction_in(4 downto 0); -- LSL/LSR
			else
				imm_data_out <= instruction_in(7 downto 0);	-- B/IMMEDIATE
			
			case instruction_in(14 downto 11) is
				when "1001" | "1010" | "1101" => 
					write_enable_out <= '0';  -- write is off for B, BEQ, ST
				when others =>
					write_enable_out <= '1';
			end case;
		end if;
	end process;
end Behavioral;