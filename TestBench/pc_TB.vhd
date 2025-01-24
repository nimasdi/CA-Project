library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tb is
end pc_tb;

architecture TB_ARCHITECTURE of pc_tb is
    -- Component declaration for the tested unit
    component pc
        port (
            clk_in : in std_logic;
            pc_op_in : in std_logic_vector(1 downto 0);
            pc_in : in std_logic_vector(15 downto 0);
            pc_out : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Signals for the testbench
    signal clk_in : std_logic := '0';
    signal pc_op_in : std_logic_vector(1 downto 0) := "00";
    signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_out : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Unit Under Test port map
    UUT : pc
        port map (
            clk_in => clk_in,
            pc_op_in => pc_op_in,
            pc_in => pc_in,
            pc_out => pc_out
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            clk_in <= '0';
            wait for clk_period / 2;
            clk_in <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Test Case 1: Reset
        pc_op_in <= "00";
        wait for clk_period;
        assert pc_out = x"0000" report "Reset failed!" severity error;

        -- Test Case 2: Increment
        pc_op_in <= "01";
        wait for clk_period;
        assert pc_out = x"0001" report "Increment failed at step 1!" severity error;

        -- Test Case 3: Branch
        pc_op_in <= "10";
        pc_in <= x"1234";
        wait for clk_period;
        assert pc_out = x"1234" report "Branch failed!" severity error;

        -- Test Case 4: NOP
        pc_op_in <= "11";
        wait for clk_period;
        assert pc_out = x"1234" report "NOP failed!" severity error;

        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_pc of pc_tb is
    for TB_ARCHITECTURE
        for UUT : pc
            use entity work.pc(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_pc;
