library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
-- Testbench has no ports
end alu_tb;

architecture Behavioral of alu_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component alu
        Port (
            clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
            pc_in : in STD_LOGIC_VECTOR (15 downto 0);
            rM_data_in : in STD_LOGIC_VECTOR (15 downto 0);
            rN_data_in : in STD_LOGIC_VECTOR (15 downto 0);
            imm_data_in : in STD_LOGIC_VECTOR (7 downto 0);
            result_out : out STD_LOGIC_VECTOR (15 downto 0);
            branch_out : out STD_LOGIC;
            rD_write_enable_in : in STD_LOGIC;
            rD_write_enable_out : out STD_LOGIC
        );
    end component;

    -- Signals for connecting to the UUT
    signal clk : STD_LOGIC := '0';
    signal enable : STD_LOGIC := '0';
    signal alu_op : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
    signal pc : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal rM_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal rN_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal imm_data : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR (15 downto 0);
    signal branch : STD_LOGIC;
    signal rD_write_enable_in : STD_LOGIC := '0';
    signal rD_write_enable_out : STD_LOGIC;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: alu
        Port map (
            clk_in => clk,
            enable_in => enable,
            alu_op_in => alu_op,
            pc_in => pc,
            rM_data_in => rM_data,
            rN_data_in => rN_data,
            imm_data_in => imm_data,
            result_out => result,
            branch_out => branch,
            rD_write_enable_in => rD_write_enable_in,
            rD_write_enable_out => rD_write_enable_out
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Test 1: ADD operation (unsigned)
        enable <= '1';
        alu_op <= "00000"; -- Unsigned addition
        rM_data <= x"000A"; -- 10
        rN_data <= x"0005"; -- 5
        wait for clk_period;
        
        -- Test 2: SUB operation (unsigned)
        alu_op <= "00001"; -- Unsigned subtraction
        rM_data <= x"000A"; -- 10
        rN_data <= x"0003"; -- 3
        wait for clk_period;

        -- Test 3: AND operation
        alu_op <= "00011"; -- Bitwise AND
        rM_data <= x"00FF"; -- 255
        rN_data <= x"0F0F"; -- 3855
        wait for clk_period;

        -- Test 4: OR operation
        alu_op <= "00100"; -- Bitwise OR
        rM_data <= x"00F0"; -- 240
        rN_data <= x"0F0F"; -- 3855
        wait for clk_period;

        -- Test 5: XOR operation
        alu_op <= "00101"; -- Bitwise XOR
        rM_data <= x"00FF"; -- 255
        rN_data <= x"000F"; -- 15
        wait for clk_period;

        -- Test 6: Shift left
        alu_op <= "00110"; -- Shift left
        rM_data <= x"0001"; -- 1
        rN_data <= x"0004"; -- Shift by 4
        wait for clk_period;

        -- Test 7: Immediate data
        alu_op <= "10011"; -- Load immediate data
        imm_data <= x"AA";
        wait for clk_period;

        -- Test 8: Branch operation
        alu_op <= "10001"; -- Branch if immediate
        rN_data <= x"8000"; -- Condition met
        wait for clk_period;

        -- End simulation
        wait;
    end process;

end Behavioral;
