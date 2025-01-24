library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;



entity alu is
    Port ( clk_in : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           rM_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           rN_data_in : in STD_LOGIC_VECTOR (15 downto 0);
           imm_data_in : in STD_LOGIC_VECTOR (7 downto 0);
           result_out : out STD_LOGIC_VECTOR (15 downto 0);
           branch_out : out STD_LOGIC;
           rD_write_enable_in : in STD_LOGIC;
           rD_write_enable_out : out STD_LOGIC);
end alu;


architecture Behavioral of alu is
    signal add_signed_ovfl : STD_LOGIC_VECTOR (15 downto 0);
    signal sub_signed_ovfl : STD_LOGIC_VECTOR (15 downto 0);
    signal is_both_positive : STD_LOGIC;
    signal is_both_negative : STD_LOGIC;
    signal overflow : STD_LOGIC;	   
	signal error : STD_Logic := '0';
     
begin
    process(clk_in)
    begin		   
        if rising_edge(clk_in) and enable_in='1' then
        
            rD_write_enable_out <= rD_write_enable_in;
            
            sub_signed_ovfl <= STD_LOGIC_VECTOR(signed(rM_data_in) - signed(rN_data_in));
            add_signed_ovfl <= STD_LOGIC_VECTOR(signed(rM_data_in) + signed(rN_data_in));
            
            
            if rM_data_in(rM_data_in'left) = '0' and rN_data_in(rN_data_in'left) = '0' then
                is_both_positive <= '1';
            else
                is_both_positive <= '0';
            end if;
            
            if rM_data_in(rM_data_in'left) = '1' and rN_data_in(rN_data_in'left) = '1' then
                is_both_negative <= '1';
            else
                is_both_negative <= '0';
            end if;
           
            if (signed(add_signed_ovfl) < 0 and is_both_positive = '1') or (signed(add_signed_ovfl) > 0 and is_both_negative = '1') then
                overflow <= '1';
            else
                overflow <= '0';
            end if;
            
            case alu_op_in(3 downto 0) is 
            
                when "0000" => 
                    if alu_op_in(4) = '1' then
                        if overflow = '1' then
                            result_out <= add_signed_ovfl;
                            assert error = '0' 
							report "we have overflow"
							severity WARNING;
                        else
                            result_out <= add_signed_ovfl;
                        end if;    
                    else
                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) + unsigned(rN_data_in));
                        
                    end if;
                    
                    branch_out <= '0';
                    
                when "0001" =>
                    if alu_op_in(4) = '1' then
                        if overflow = '1' then
                            result_out <= sub_signed_ovfl;
							assert error = '0' 
							report "we have overflow"
							severity WARNING;
                        else
                            result_out <= sub_signed_ovfl;
                        end if;
                    else
                        result_out <= STD_LOGIC_VECTOR(unsigned(rM_data_in) - unsigned(rN_data_in));
                        
                    end if;
                    
                    branch_out <= '0';
                    
                when "0010" => 
                    result_out <= not rM_data_in;
                    branch_out <= '0';
                    
                when "0011" => 
                    result_out <= rM_data_in and rN_data_in;
                    branch_out <= '0';
                    
                when "0100" => 
                    result_out <= rM_data_in or rN_data_in;
                    branch_out <= '0';
                    
                when "0101" => 
                    result_out <= rM_data_in xor rN_data_in;
                    branch_out <= '0';
                    
                when "0110" => 
                    result_out <= STD_LOGIC_VECTOR(shift_left(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
                    branch_out <= '0';
                    
                when "0111" => 
                    result_out <= STD_LOGIC_VECTOR(shift_right(unsigned(rM_data_in), to_integer(unsigned(rN_data_in(3 downto 0)))));
                    branch_out <= '0';
                    
                when "1000" => 
                    
                    if alu_op_in(4) = '1' and signed(sub_signed_ovfl) < 0 then
                        result_out(15) <= '1';
                    else
                        result_out(15) <= '0';
                    end if;
                    
                    if unsigned(rM_data_in) - unsigned(rN_data_in) = 0 then
                        result_out(14) <= '1';
                    else 
                        result_out(14) <= '0';
                    end if;
                    
                    if alu_op_in(4) = '0' and unsigned(rM_data_in) - unsigned(rN_data_in) > unsigned(rM_data_in) + unsigned(rN_data_in) then
                        result_out(13) <= '1';
                    else
                        result_out(13) <= '0';
                    end if;
                    -- Ver (signed overflow)
                    if alu_op_in(4) = '1' and overflow ='1' then
                        result_out(12) <= '1';
                    else
                        result_out(12) <= '0';
                    end if;
                    
                    result_out(11 downto 0) <= x"000";
                    
                    
                    branch_out <= '0';
                    
                when "1001" => 
                    if alu_op_in(4) = '1' then
                        result_out <= x"00" & imm_data_in;
                    else
                        result_out <= rM_data_in;
                    end if;
                    branch_out <= '1';
                    
                when "1010" =>
                    if rN_data_in(14) = '1' then
                        result_out <= rM_data_in;
                        branch_out <= '1';
                    else
                        branch_out <= '0';
                    end if;
                    
                when "1011" => 
                    if alu_op_in(4) = '1' then
                        result_out <= imm_data_in & x"00";
                    else
                        result_out <= x"00" & imm_data_in;
                    end if;
                    
                    branch_out <= '0';
                    
                when "1100" => 
                    result_out <= rM_data_in;
                    branch_out <= '0';
                    
                when "1101" => 
                    result_out <= rM_data_in;
                    branch_out <= '0';
                    
                when others =>
                    NULL;
            end case;
        end if;                                           
    end process;


end Behavioral;