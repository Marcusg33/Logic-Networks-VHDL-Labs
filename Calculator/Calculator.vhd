library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Calculator is
    Port (
        clock : in std_logic;
        reset : in std_logic;
        SW : in std_logic_vector( 15 downto 0 );
        BTNC, BTNU, BTNL, BTNR, BTND : in std_logic;
        LED : out std_logic_vector( 15 downto 0 );
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; --! modify the constraint file accordingly
        AN : out std_logic_vector( 3 downto 0 )
    );
end Calculator;

architecture Behavioral of Calculator is

-- Internal signals for debouncers
    signal center_edge, up_edge, left_edge, right_edge, down_edge : std_logic;
    -- Input/output signals for accumulator
    signal acc_in, acc_out : signed( 15 downto 0 );
    -- Init and load signals for accumulator
    signal acc_init, acc_enable : std_logic;
    -- Control signals for ALU
    signal do_add, do_sub, do_mult, do_div : std_logic;
    -- The accumulator output should be converted to std_logic_vector
    signal display_value : std_logic_vector( 15 downto 0 );
    -- Signals for input switches
    signal sw_input : std_logic_vector( 15 downto 0 );

    -- Components declaration:
    component Debouncer is
        generic(
            counter_size : integer := 12
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            bouncy : in std_logic;
            pulse : out std_logic
        );
    end component Debouncer;

    component Accumulator is
        port (
            clk : in std_logic;
            rst : in std_logic;
            ac_init : in std_logic;
            ac_enable : in std_logic;
            data_in : in signed(15 downto 0);
            result_out : out signed(15 downto 0)
        );
    end component Accumulator;

    component ALU is
        Port (
            a : in signed( 15 downto 0 );
            b : in signed( 15 downto 0 );  
            add : in std_logic;
            subtract : in std_logic;
            multiply : in std_logic;
            divide : in std_logic;
            r : out signed( 15 downto 0 )
        );
    end component ALU;

    component Seven_segment_driver is
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

    end component Seven_segment_driver;
 
begin

    -- Buttons Declaration:
    center_detect : Debouncer
    port map (
        clk => clock,
        rst => reset,
        bouncy => BTNC,
        pulse => center_edge
    );
  
    up_detect : Debouncer
    port map (
        clk => clock,
        rst => reset,
        bouncy => BTNU,
        pulse => up_edge
    );
    
    down_detect : Debouncer
    port map (
        clk => clock,
        rst => reset,
        bouncy => BTND,
        pulse => down_edge
    );
    
    left_detect : Debouncer
    port map (
        clk => clock,
        rst => reset,
        bouncy => BTNL,
        pulse => left_edge
    );

    right_detect : Debouncer
    port map (
        clk => clock,
        rst => reset,
        bouncy => BTNR,
        pulse => right_edge
    );
  
    -- Instantiate the seven segment display driver
    the_driver : Seven_segment_driver
    generic map ( 
        size => 21
    ) port map (
        clk => clock,
        rst => reset,
        binary_input => display_value,
        CA => CA,
        CB => CB,
        CC => CC,
        CD => CD,
        CE => CE,
        CF => CF,
        CG => CG,
        DP => DP,
        AN => AN
    );

    -- Instantiate the accumulator
    the_accumulator : Accumulator
    port map (
        clk => clock,
        rst => reset,
        ac_init => acc_init,
        ac_enable => acc_enable,
        data_in => acc_in,
        result_out => acc_out
    );

    -- Instantiate the ALU
    the_alu : ALU
    port map (
        a => acc_out,
        b => signed( sw_input ),
        add => do_add,
        subtract => do_sub,
        multiply => do_mult,
        divide => do_div,
        r => acc_in
    );

    -- Control logic
    display_value <= std_logic_vector( acc_out );
    LED <= std_logic_vector( acc_out );

    -- Operations input
    process(clock, reset)
    begin
        if reset = '0' then
            acc_init <= '0';
            acc_enable <= '0';
            do_add <= '0';
            do_sub <= '0';
            do_mult <= '0';
            do_div <= '0';
        elsif rising_edge(clock) then
            -- Default values
            acc_init <= '0';
            acc_enable <= '0';
            do_add <= '0';
            do_sub <= '0';
            do_mult <= '0';
            do_div <= '0';

            -- Load switches input
            sw_input <= SW;

            -- Check which button was pressed
            if center_edge = '1' then
                acc_init <= '1';
            elsif up_edge = '1' then
                acc_enable <= '1';
                do_add <= '1';
            elsif down_edge = '1' then
                acc_enable <= '1';
                do_sub <= '1';
            elsif right_edge = '1' then
                acc_enable <= '1';
                do_mult <= '1';
            elsif left_edge = '1' then
                acc_enable <= '1';
                do_div <= '1';
            end if;
        end if;
    end process;

end Behavioral;