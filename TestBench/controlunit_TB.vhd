library ieee;
use ieee.std_logic_1164.all;

entity controlunit_tb is
end controlunit_tb;

architecture TB_ARCHITECTURE of controlunit_tb is
    -- Component declaration of the tested unit
    component controlunit
        port(
            clk_in : in STD_LOGIC;
            reset_in : in STD_LOGIC;
            alu_op_in : in STD_LOGIC_VECTOR(4 downto 0);
            stage_out : out STD_LOGIC_VECTOR(5 downto 0)
        );
    end component;

    -- Stimulus signals
    signal clk_in : STD_LOGIC := '0';
    signal reset_in : STD_LOGIC := '0';
    signal alu_op_in : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal stage_out : STD_LOGIC_VECTOR(5 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Unit Under Test port map
    UUT : controlunit
        port map (
            clk_in => clk_in,
            reset_in => reset_in,
            alu_op_in => alu_op_in,
            stage_out => stage_out
        );

    -- Clock signal generation
    clk_process : process
    begin
        clk_in <= '0';
        wait for CLK_PERIOD / 2;
        clk_in <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initial reset
        reset_in <= '1';
        wait for CLK_PERIOD;
        assert stage_out = "000001" report "Reset failed. stage_out is not '000001'" severity error;

        reset_in <= '0';
        wait for CLK_PERIOD;

        -- Test Fetch -> Decode
        assert stage_out = "000010" report "Stage transition from Fetch to Decode failed." severity error;

        -- Test Decode -> Reg Read
        wait for CLK_PERIOD;
        assert stage_out = "000100" report "Stage transition from Decode to Reg Read failed." severity error;

        -- Test Reg Read -> Execute
        wait for CLK_PERIOD;
        assert stage_out = "001000" report "Stage transition from Reg Read to Execute failed." severity error;

        -- Test Execute with ALU operation (Load or Store)
        alu_op_in <= "01100"; -- LD operation (5 bits)
        wait for CLK_PERIOD;
        assert stage_out = "010000" report "Stage transition for LD operation failed." severity error;

        -- Test Memory -> Reg Write
        wait for CLK_PERIOD;
        assert stage_out = "100000" report "Stage transition from Memory to Reg Write failed." severity error;

        -- Test Reg Write -> Fetch
        wait for CLK_PERIOD;
        assert stage_out = "000001" report "Stage transition from Reg Write to Fetch failed." severity error;

        -- Test Execute with non-LD/ST operation
        alu_op_in <= "00001"; -- Non-LD/ST operation (5 bits)
        wait for CLK_PERIOD * 4; -- Wait for the Execute stage
        assert stage_out = "100000" report "Stage transition for non-LD/ST operation failed." severity error;

        -- Final reset to check looping behavior
        reset_in <= '1';
        wait for CLK_PERIOD;
        assert stage_out = "000001" report "Final reset failed." severity error;

        report "All test cases passed successfully." severity note;
        wait;
    end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_controlunit of controlunit_tb is
    for TB_ARCHITECTURE
        for UUT : controlunit
            use entity work.controlunit(behavioral);
        end for;
    end for;
end TESTBENCH_FOR_controlunit;
