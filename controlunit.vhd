							   library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

	
entity controlunit is
    port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           stage_out : out STD_LOGIC_VECTOR (5 downto 0));
end controlunit;


architecture behavioral of controlunit is
    signal s_var: STD_LOGIC_VECTOR(5 downto 0) := "000001";

begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset_in = '1' then
                s_var <= "000001";
            else
                case s_var is		 
					when "100000" => -- Reg write
                        s_var <= "000001";
                    when "010000" => -- Memory
                   	    s_var <= "100000";
					when "000001" => -- Fetch
                        s_var <= "000010";
                    when "000010" => -- Decode
                        s_var <= "000100";
                    when "000100" => -- Reg read
                        s_var <= "001000";
                    when "001000" => -- Execute
                        if alu_op_in(3 downto 0) = "1100" or alu_op_in(3 downto 0) = "1101" then --Load or Store
                            s_var <= "010000";
                        else
                            s_var <= "100000";
                        end if;

                    when others =>
                        s_var <= "000001";
                end case;
            end if;
        end if;
    end process;

    stage_out <= s_var;
	
end behavioral;