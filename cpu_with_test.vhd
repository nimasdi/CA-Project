																												library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    --Port ( clk_in : in STD_LOGIC;
    --       reset : in STD_LOGIC);
end cpu;

architecture Behavioral of cpu is

    component registerfile
    Port ( clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            write_enable_in : in STD_LOGIC;
            rM_data_out : out STD_LOGIC_VECTOR (15 downto 0);
            rN_data_out : out STD_LOGIC_VECTOR (15 downto 0);
            rD_data_in : in STD_LOGIC_VECTOR (15 downto 0);
            sel_rM_in : in STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_in : in STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_in : in STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component decoder
    Port ( clk_in : in STD_LOGIC;
            enable_in : in STD_LOGIC;
            instruction_in : in STD_LOGIC_VECTOR (15 downto 0);
            alu_op_out : out STD_LOGIC_VECTOR (4 downto 0);
            imm_data_out : out STD_LOGIC_VECTOR (7 downto 0); -- 16 or 8
            write_enable_out : out STD_LOGIC;
            sel_rM_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rN_out : out STD_LOGIC_VECTOR (2 downto 0);
            sel_rD_out : out STD_LOGIC_VECTOR (2 downto 0));
    end component;
    
    component alu
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
    end component;
    
    component controlunit
    Port ( clk_in : in STD_LOGIC;
           reset_in : in STD_LOGIC;
           alu_op_in : in STD_LOGIC_VECTOR (4 downto 0);
           stage_out : out STD_LOGIC_VECTOR (5 downto 0));
    end component;
    
    component pcunit
    Port ( clk_in : in STD_LOGIC;
           pc_op_in : in STD_LOGIC_VECTOR (1 downto 0);
           pc_in : in STD_LOGIC_VECTOR (15 downto 0);
           pc_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component ram
    Port ( clk_in : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable_in : in STD_LOGIC;
           write_enable_in : in STD_LOGIC;
           address_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    signal reg_enable : STD_LOGIC := '0'; --regfile
    signal reg_write_enable : STD_LOGIC := '0'; --regfile
    signal rM_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rN_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rD_data : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --regfile
    signal rM_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    signal rN_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    signal rD_sel : STD_LOGIC_VECTOR (2 downto 0) := (others => '0'); --regfile
    
    signal instruction : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --decoder --alu
    signal alu_op : STD_LOGIC_VECTOR (4 downto 0) := (others => '0'); --decoder --alu --controlunit
    signal immediate : STD_LOGIC_VECTOR (7 downto 0) := (others => '0'); --decoder --alu
    
    signal result : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --alu
    signal branch : STD_LOGIC := '0'; --alu
    signal rD_write_enable : STD_LOGIC := '0'; --alu
    signal rD_write_enable_1 : STD_LOGIC := '0'; --alu
    
    signal cpu_reset : STD_LOGIC := '0'; --controlunit --ram
    
    signal stage : STD_LOGIC_VECTOR (5 downto 0) := (others => '0'); --controlunit
    
    signal pc_op : STD_LOGIC_VECTOR (1 downto 0) := (others => '0'); --pc
    signal pc_in : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --pc
    signal pc_out : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --pc
    
    signal ram_write_enable : STD_LOGIC := '0'; -- ram
    signal address : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    signal ram_data_in : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    signal ram_data_out : STD_LOGIC_VECTOR (15 downto 0) := (others => '0'); --ram
    
    signal fetch_enable : STD_LOGIC := '0'; --pipeline
    signal reg_read : STD_LOGIC := '0'; --pipeline
    signal decoder_enable : STD_LOGIC := '0'; --pipeline
    signal alu_enable : STD_LOGIC := '0'; --pipeline
    signal ram_enable : STD_LOGIC := '0'; --pipeline
    signal reg_write : STD_LOGIC := '0'; --pipeline
    
    signal cpu_clock : STD_LOGIC := '0';   --all
    
    constant clk_period : time := 10 ns;
    

begin

    cpu_registerfile : registerfile PORT MAP (
        clk_in => cpu_clock,
        enable_in => reg_enable,
        write_enable_in => reg_write_enable,
        rM_data_out => rM_data,
        rN_data_out => rN_data,
        rD_data_in => rD_data,
        sel_rM_in => rM_sel,
        sel_rN_in => rN_sel,
        sel_rD_in => rD_sel
    );
    
    cpu_decoder : decoder PORT MAP (
        clk_in => cpu_clock,
        enable_in => decoder_enable,
        instruction_in => instruction,
        alu_op_out => alu_op,
        imm_data_out => immediate,
        write_enable_out => rD_write_enable,
        sel_rM_out => rM_sel,
        sel_rN_out => rN_sel,
        sel_rD_out => rD_sel
    );
    
    cpu_alu : alu PORT MAP (
        clk_in => cpu_clock,
        enable_in => alu_enable,
        alu_op_in => alu_op,
        pc_in => pc_out,
        rM_data_in => rM_data,
        rN_data_in => rN_data,
        imm_data_in => immediate,
        result_out => result,
        branch_out => branch,
        rD_write_enable_in => rD_write_enable,
        rD_write_enable_out => rD_write_enable_1
    );
    
    cpu_controlunit : controlunit PORT MAP (
        clk_in => cpu_clock,
        reset_in => cpu_reset,
        alu_op_in => alu_op,
        stage_out => stage
    );
        
    cpu_pcunit : pcunit PORT MAP (
        clk_in => cpu_clock,
        pc_op_in => pc_op,
        pc_in => pc_in,
        pc_out => pc_out
    );
        
    cpu_ram : ram PORT MAP (
        clk_in => cpu_clock,
        reset => cpu_reset,
        enable_in => ram_enable,
        write_enable_in => ram_write_enable,
        address_in => address,
        data_in => ram_data_in,
        data_out => ram_data_out
    );
    
--CPU    
    --cpu_clock <= clk_in;
    --cpu_reset <= reset;
    
--REGISTER FILE
    reg_enable <= reg_read or reg_write;
    reg_write_enable <= rD_write_enable_1 and reg_write;
    
--PIPELINE   
    fetch_enable <= stage(0); -- fetch
    decoder_enable <= stage(1); -- decode
    reg_read <= stage(2); -- register read
    alu_enable <= stage(3); -- execute
    ram_enable <= stage(4); -- memory
    reg_write <= stage(5); -- register write

--PC
    pc_op <= "00" when cpu_reset = '1' else -- reset
             "01" when branch = '0' and stage(5) = '1' else -- increment
             "10" when branch = '1' and stage(5) = '1' else -- jump
             "11"; -- nop

    pc_in <= result;

--MEMORY   
    address <= result when ram_enable = '1' else pc_out; -- the ram access is either during memory stage or fetch stage
    ram_data_in <= rN_data; -- rN contains data, rM contains address for ST
    ram_write_enable <= '1' when ram_enable = '1' and alu_op(3 downto 0) = "1101" else '0'; -- ram_enable and a ST
    
    rD_data <= ram_data_out when reg_write = '1' and alu_op(3 downto 0) = "1100" else result; --register data is either ram when LD or alu result
    
    instruction <= ram_data_out when fetch_enable = '1'; -- data from ram goes to decoder

 --TESTING
 
    clk_process : process
    begin
         cpu_clock <= '0';
         wait for clk_period/2;
         cpu_clock <= '1';
         wait for clk_period/2;
    end process;

    stim_proc: process
    begin      
        
        cpu_reset <= '1'; -- Reset control unit and program counter
        wait for clk_period;
        cpu_reset <= '0';
        wait until reg_write = '1';
        
        instruction <= x"0000"; -- No operation (NOP)
        
        -- Test Immediate Load Instructions
        -- Load immediate value 0x0F into register r0
        instruction <= '0' & "1011" & "000" & x"0F"; -- IMM r0 = 0x000F
        wait until reg_write = '1';
        
        -- Load immediate value 0xBB into register r1
        instruction <= '0' & "1011" & "001" & x"BB"; -- IMM r1 = 0x00BB
        wait until reg_write = '1';
        
        -- Test Bitwise NOT Operation
        instruction <= '0' & "0010" & "001" & "001" & "00000"; -- NOT r1 (Bitwise complement)
        wait until reg_write = '1';
        
        -- Test Unsigned Addition
        instruction <= '0' & "0000" & "010" & "001" & "000" & "00"; -- ADD r2 = r1 + r0
        wait until reg_write = '1';
        
        -- Test Immediate Load and Shift Operations
        instruction <= '0' & "1011" & "011" & x"0C"; -- IMM r3 = 0x0C (Shift amount)
        wait until reg_write = '1';
        
        -- Logical Shift Left
        instruction <= '0' & "0110" & "010" & "010" & "011" & "00"; -- LSL r2 by r3
        wait until reg_write = '1';
        
        -- Load another immediate for shift
        instruction <= '0' & "1011" & "100" & x"06"; -- IMM r4 = 0x06 (Another shift amount)
        wait until reg_write = '1';
        
        -- Logical Shift Right
        instruction <= '0' & "0111" & "010" & "010" & "100" & "00"; -- LSR r2 by r4
        wait until reg_write = '1';
        
        -- Test Branch Instruction
        instruction <= '1' & "1001" & "000" & x"0D"; -- Unconditional Branch to RAM address 13
        wait until reg_write = '1';
        
        -- Two No-Operation Instructions
        instruction <= x"0000"; -- NOP
        wait until reg_write = '1';
        
        instruction <= x"0000"; -- NOP
        wait until reg_write = '1';
        
        -- Test Unsigned Subtraction
        instruction <='0' & "0001" & "101" & "010" & "011" & "00"; -- SUB r5 = r2 - r3
        wait until reg_write = '1';
        
        -- Prepare for Store and Load Tests
        instruction <='0' & "1011" & "110" & x"EE"; -- IMM r6 = 0xEE (Memory address)
        wait until reg_write = '1';
        
        -- Store Operation
        instruction <='0' & "1101" & "000" & "110" & "101" & "00"; -- ST Store r5 to memory address in r6
        wait until reg_write = '1';
        
        -- Load Operation
        instruction <='0' & "1100" & "111" & "110" & "00000"; -- LD Load from r6 address to r7
        wait until reg_write = '1';
        
        -- Test Compare Instruction
        instruction <='0' & "1000" & "000" & "101" & "111" & "00"; -- CMP Compare r5 and r7, result in r0
        wait until reg_write = '1';
        
        -- More Immediate Loads and Conditional Branch
        instruction <='0' & "1011" & "001" & x"1C"; -- IMM r1 = 0x1C
        wait until reg_write = '1';
        
        -- Branch if Equal
        instruction <='0' & "1010" & "000" & "001" & "000" & "00"; -- BEQ Branch if Equal
        wait until reg_write = '1';
        
        -- No-Operation Instructions
        instruction <=x"0000"; -- NOP
        wait until reg_write = '1';
        
        instruction <= x"0000"; -- NOP
        wait until reg_write = '1';
        
        -- Bitwise Logic Operations
        instruction <='0' & "0011" & "010" & "011" & "001" & "00"; -- AND r2 = r3 AND r1
        wait until reg_write = '1';
        
        instruction <='0' & "0100" & "011" & "010" & "001" & "00"; -- OR r3 = r2 OR r1
        wait until reg_write = '1';
         
        instruction <='0' & "0101" & "100" & "011" & "011" & "00"; -- XOR r4 = r3 XOR r3
        wait until reg_write = '1';
        
        wait; -- Terminate simulation
        
    end process;


end Behavioral;