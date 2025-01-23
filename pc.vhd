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
	signal tmp: std_logic_vector(15 downto 0) := x"0000";
begin
	process(clk_in)
	begin
		if rising_edge(clk_in) then
			case pc_op_in is
				when "00" =>
					tmp <= x"0000";
				when "01" =>
					tmp <= std_logic_vector(unsigned(tmp) + 1);
				when "10" => 
					tmp <= pc_in;
				when "11" =>   
					null;
				when others =>
					tmp <= tmp;
	end process;			 
	
	pc_out <= tmp;
	
end Behavioral;