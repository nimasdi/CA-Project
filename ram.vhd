library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram is
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           write_enable_in : in STD_LOGIC;
           address_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end ram;

architecture Behavioral of ram is
    type ram_array is array (0 to 255) of STD_LOGIC_VECTOR (15 downto 0); -- 256 addresses of 16 bits = 512B memory
    --signal ram: ram_array := (others => x"0000");
    signal ram: ram_array := (
        -- Test Program Instructions
        '0' & "1011" & "000" & x"1F", -- imm r0 = 0x1F (581F)                                                     0
        '0' & "1011" & "001" & x"07", -- imm r1 = 0x07 (5907)                                                     1
        '0' & "0000" & "010" & "001" & "000" & "00", -- ADD r2, r1, r0 (0220)                                     2
        '0' & "1101" & "000" & "010" & "010" & "00", -- ST r2 (data) at address r2 (68A0)                         3
        '0' & "1100" & "011" & "010" & "00000", -- LD r2 (address) into r3 (6340)                                 4
        '0' & "0001" & "100" & "011" & "001" & "00", -- SUB r4, r3, r1 (0C64)                                     5
        '0' & "0010" & "101" & "100" & "00000", -- NOT r5, r4 (1580)                                              6
        '0' & "0011" & "110" & "000" & "001" & "00", -- AND r6, r0, r1 (1E04)                                     7
        '0' & "0100" & "111" & "110" & "101" & "00", -- OR r7, r6, r5 (27D4)                                      8
        '0' & "0101" & "000" & "111" & "100" & "00", -- XOR r0, r7, r4 (2870) 									  9
        others => x"0000"
    );
    
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            --if(reset = '1') then
            --    ram <= (others => x"0000");
            --end if;
            if(write_enable_in = '1') then
                ram(to_integer(unsigned(address_in(7 downto 0)))) <= data_in; -- 2^8 = 256
            else
                data_out <= ram(to_integer(unsigned(address_in(7 downto 0))));
            end if;
        end if;
     end process;

end Behavioral;
