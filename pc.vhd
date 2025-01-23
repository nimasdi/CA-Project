library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is
	port(clk_in: in std_logic;
		pc_op_in: in std_logic_vector(1 downto 0);	  
		pc_in: in std_logic_vector(15 downto 0);
		pc_out: out std_logic_vector(15 downto 0));
end pc;

architecture Behavioral of pc is
	signal pc: std_logic_vector(15 downto 0) := x"0000";
begin
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			case pc_op_in is
				when "00" =>
					pc <= x"0000";
				when "01" =>
					pc <= std_logic_vector(unsigned(pc) + 1);
				when "10" => 
					pc <= pc_in;
				when "11" => 
				when others =>
	end process;			 
	
	pc_out <= pc;
	
end Behavioral;