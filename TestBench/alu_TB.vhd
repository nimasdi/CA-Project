library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

entity alu_tb is
end alu_tb;

architecture TB_ARCHITECTURE of alu_tb is
    -- Component declaration of the tested unit
    component alu
        port(
            clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            alu_op_in : in STD_LOGIC_VECTOR(4 downto 0);
            pc_in : in STD_LOGIC_VECTOR(15 downto 0);
            rM_data_in : in STD_LOGIC_VECTOR(15 downto 0);
            rN_data_in : in STD_LOGIC_VECTOR(15 downto 0);
            imm_data_in : in STD_LOGIC_VECTOR(7 downto 0);
            result_out : out STD_LOGIC_VECTOR(15 downto 0);
            branch_out : out STD_LOGIC;
            rD_write_enable_in : in STD_LOGIC;
            rD_write_enable_out : out STD_LOGIC );
    end component;

    -- Stimulus signals
    signal clk_in : STD_LOGIC := '0';
    signal enable_in : STD_LOGIC := '0';
    signal alu_op_in : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal pc_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal rM_data_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal rN_data_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal imm_data_in : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rD_write_enable_in : STD_LOGIC := '0';

    -- Observed signals
    signal result_out : STD_LOGIC_VECTOR(15 downto 0);
    signal branch_out : STD_LOGIC;
    signal rD_write_enable_out : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Unit Under Test port map
    UUT : alu
        port map (
            clk_in => clk_in,
            enable_in => enable_in,
            alu_op_in => alu_op_in,
            pc_in => pc_in,
            rM_data_in => rM_data_in,
            rN_data_in => rN_data_in,
            imm_data_in => imm_data_in,
            result_out => result_out,
            branch_out => branch_out,
            rD_write_enable_in => rD_write_enable_in,
            rD_write_enable_out => rD_write_enable_out
        );

    -- Clock process definitions
    clk_process : process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        enable_in <= '1';
        rD_write_enable_in <= '1';
        wait for clk_period;

        -- Test case 1: Addition (unsigned)
        alu_op_in <= "00000"; -- Unsigned addition
        rM_data_in <= x"0005";
        rN_data_in <= x"0003";
        wait for clk_period;
        assert result_out = x"0008" report "Test case 1 failed" severity error;

        -- Test case 2: Subtraction (unsigned)
        alu_op_in <= "00001"; -- Unsigned subtraction
        rM_data_in <= x"0005";
        rN_data_in <= x"0003";
        wait for clk_period;
        assert result_out = x"0002" report "Test case 2 failed" severity error;

        -- Test case 3: Logical NOT
        alu_op_in <= "00010"; -- Logical NOT
        rM_data_in <= x"00FF";
        wait for clk_period;
        assert result_out = x"FF00" report "Test case 3 failed" severity error;

        -- Test case 4: Logical AND
        alu_op_in <= "00011"; -- Logical AND
        rM_data_in <= x"00FF";
        rN_data_in <= x"0F0F";
        wait for clk_period;
        assert result_out = x"000F" report "Test case 4 failed" severity error;

        -- Test case 5: Logical OR
        alu_op_in <= "00100"; -- Logical OR
        rM_data_in <= x"00FF";
        rN_data_in <= x"0F0F";
        wait for clk_period;
        assert result_out = x"0FFF" report "Test case 5 failed" severity error;

        -- Test case 6: Logical XOR
        alu_op_in <= "00101"; -- Logical XOR
        rM_data_in <= x"00FF";
        rN_data_in <= x"0F0F";
        wait for clk_period;
        assert result_out = x"0FF0" report "Test case 6 failed" severity error;

        -- Test case 7: Shift left
        alu_op_in <= "00110"; -- Shift left
        rM_data_in <= x"0001";
        rN_data_in <= x"0003"; -- Shift by 3
        wait for clk_period;
        assert result_out = x"0008" report "Test case 7 failed" severity error;

        -- Test case 8: Shift right
        alu_op_in <= "00111"; -- Shift right
        rM_data_in <= x"0008";
        rN_data_in <= x"0002"; -- Shift by 2
        wait for clk_period;
        assert result_out = x"0002" report "Test case 8 failed" severity error;

        -- Test case 9: Branch with immediate
        alu_op_in <= "11001"; -- Branch with immediate
        imm_data_in <= x"AA";
        wait for clk_period;
        assert result_out = x"00AA" and branch_out = '1' report "Test case 9 failed" severity error;

        -- Test case 10: Branch with register
        alu_op_in <= "11010"; -- Branch with register 
		rN_data_in <= x"ffff";
        rM_data_in <= x"1234";
        wait for clk_period;
        assert result_out = x"1234" and branch_out = '1' report "Test case 10 failed" severity error;

        -- End of test
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_alu of alu_tb is
    for TB_ARCHITECTURE
        for UUT : alu
            use entity work.alu(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_alu;