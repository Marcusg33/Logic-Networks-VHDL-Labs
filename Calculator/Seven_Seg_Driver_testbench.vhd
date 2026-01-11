library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_testbench is
end seven_seg_testbench;

architecture Behavioral of seven_seg_testbench is

    -- Component Declaration for the Unit Under Test (UUT)
    component Seven_segment_driver
    generic (
        size : integer := 20
    );
    Port (
        clk : in std_logic;
        rst : in std_logic;
        binary_input : in std_logic_vector( 15 downto 0 );
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 3 downto 0 )
    );
    end component;

    -- Signals to connect to UUT
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal binary_input_tb : std_logic_vector( 15 downto 0 ) := (others => '0');
    signal CA_tb, CB_tb, CC_tb, CD_tb, CE_tb, CF_tb, CG_tb, DP_tb : std_logic;
    signal AN_tb : std_logic_vector( 3 downto 0 );

    constant clk_period : time := 10 ns;

begin
     -- Instantiate the Unit Under Test (UUT)
    uut: Seven_segment_driver
    generic map (
        size => 5
    ) port map (
        clk => clk_tb,
        rst => rst_tb,
        binary_input => binary_input_tb,
        CA => CA_tb,
        CB => CB_tb,
        CC => CC_tb,
        CD => CD_tb,
        CE => CE_tb,
        CF => CF_tb,
        CG => CG_tb,
        DP => DP_tb,
        AN => AN_tb
    );

    clock : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;

    main : process
    begin
        -- Reset the UUT
        rst_tb <= '0';
        wait for clk_period * 2;
        rst_tb <= '1';
        wait for clk_period * 2;

        -- Test different binary inputs
        binary_input_tb <= "0000000000000000"; -- 0
        wait for clk_period * 100;

        binary_input_tb <= "0000000000001001"; -- 9
        wait for clk_period * 100;

        binary_input_tb <= "0000000000010101"; -- 21
        wait for clk_period * 100;

        binary_input_tb <= "0000000011111111"; -- 255
        wait for clk_period * 100;

        binary_input_tb <= "0000111111111111"; -- 4095
        wait for clk_period * 100;

        binary_input_tb <= "1111111111111111"; -- -1 in signed
        wait for clk_period * 100;

        -- End simulation
        wait;
    end process;
end architecture Behavioral;
