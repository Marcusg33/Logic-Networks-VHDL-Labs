library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_pig_game is
    port (
        CLK : in std_logic; --! system clock
        BTN : in std_logic_vector(4 downto 0); --! input buttons
        LED : out std_logic_vector(15 downto 0); --! output to 7-segment display segments
        SSEG_AN : out std_logic_vector(3 downto 0);  --! output to 7-segment display anodes
        SSEG_CA : out std_logic_vector(7 downto 0);  --! output to 7-segment display cathodes
        SW : in std_logic_vector(15 downto 0)  --! input from switches
    );
end entity main_pig_game;

architecture behavioral of main_pig_game is

    -- Components declaration
    component controlunit is
        port(
            clock  : in std_logic; --! Clock
            reset  : in std_logic; --! Reset
            ROLL   : in std_logic; --! button for the roll
            HOLD   : in std_logic; --! button for hold
            NEWGAME: in std_logic; --! button for new game
            ENADIE : out std_logic; --! Enable Die to increment
            LDSU   : out std_logic; --! Add DIE to SUR register
            LDT1   : out std_logic; --! Add SUR to TR1 register
            LDT2   : out std_logic; --! Add SUR to TR2 register
            RSSU   : out std_logic; --! Reset SUR register
            RST1   : out std_logic; --! Reset TR1 register
            RST2   : out std_logic; --! Reset TR2 register
            BP1    : out std_logic; --! enables blinking
            CP     : inout std_logic; --! current player (register outside)
            FP     : inout std_logic; --! First player (register outside)
            DIE1   : in std_logic; --! signal that the die is at one
            WN     : in std_logic --! WIN has been achieved by a player
        );
    end component controlunit;

    component datapath is
        port(
            clock  : in std_logic; --! Clock
            reset  : in std_logic; --! Reset
            ENADIE : in std_logic; --! Enable Die to increment
            LDSU   : in std_logic; --! Add DIE to SUR register
            LDT1   : in std_logic; --! Add SUR to TR1 register
            LDT2   : in std_logic; --! Add SUR to TR2 register
            RSSU   : in std_logic; --! Reset SUR register
            RST1   : in std_logic; --! Reset TR1 register
            RST2   : in std_logic; --! Reset TR2 register
            CP     : inout std_logic; --! current player (register outside)
            FP     : inout std_logic; --! First player (register outside)
            DIGIT0 : out std_logic_vector( 3 downto 0 ); --! digit to the right
            DIGIT1 : out std_logic_vector( 3 downto 0 ); --! 2nd digit to the left
            DIGIT2 : out std_logic_vector( 3 downto 0 ); --! 3rd digit to the left
            DIGIT3 : out std_logic_vector( 3 downto 0 ); --! digit to the left
            LEDDIE : out std_logic_vector(2 downto 0); --! LEDs to display the die value
            DIE1   : out std_logic; --! signal that a one has been obtained
            WN     : out std_logic --! WIN has been achieved by a player
        );
    end component datapath;

    component seven_segment_driver is
        generic (
        size : integer := 20 --! size of the counter 2^20 max
        );
        Port (
        clock  : in std_logic; --! Clock
        reset  : in std_logic; --! Reset
        digit0 : in std_logic_vector( 3 downto 0 ); --! digit to the left
        digit1 : in std_logic_vector( 3 downto 0 ); --! digit number 2 from left
        digit2 : in std_logic_vector( 3 downto 0 ); --! digit number 3 from left
        digit3 : in std_logic_vector( 3 downto 0 ); --! digit uttermost right
        CA     : out std_logic_vector(7 downto 0); --! Cathodes
        AN     : out std_logic_vector( 3 downto 0 ) --! Anodes
        );
    end component seven_segment_driver;

    component debouncer is  
        generic (
            counter_size : integer := 12
        );
        port (
            clock, reset : in std_logic; --! clock and reset
            bouncy       : in std_logic; --! input that can bounce even in less than one clock cycle (the debouncer can be connected to a slow clock)
            pulse    : out std_logic; --! send a pulse as soon as the stable state of the button touch is verified
            debounced: out std_logic --! provide an out that is the stable version
            );
    end component debouncer;

    -- Signals declaration
    signal ENADIE : std_logic; --! Enable Die to increment
    signal LDSU   : std_logic; --! Add DIE to SUR register
    signal LDT1   : std_logic; --! Add SUR to TR1 register
    signal LDT2   : std_logic; --! Add SUR to TR2 register
    signal RSSU   : std_logic; --! Reset SUR register
    signal RST1   : std_logic; --! Reset TR1 register
    signal RST2   : std_logic; --! Reset TR2 register
    signal BP1    : std_logic; --! enables blinking
    signal CP     : std_logic := '0'; --! current player (register outside)
    signal FP     : std_logic := '0'; --! First player (register outside)
    signal DIE1   : std_logic; --! signal that the die is at one
    signal WN     : std_logic; --! WIN has been achieved by a player
    signal DIGIT0 : std_logic_vector( 3 downto 0 ); --! digit to the right
    signal DIGIT1 : std_logic_vector( 3 downto 0 ); --! 2nd digit to the left
    signal DIGIT2 : std_logic_vector( 3 downto 0 ); --! 3nd digit to the left
    signal DIGIT3 : std_logic_vector( 3 downto 0 ); --! digit to the left
    signal BTN_0_DEBOUNCED : std_logic; --! debounced version of BTN(0)
    signal BTN_1_DEBOUNCED : std_logic; --! debounced version of BTN(1)
    signal BTN_2_DEBOUNCED : std_logic; --! debounced version of BTN(2)
    signal blink_scaler : unsigned(23 downto 0) := (others => '0'); --! scaler for blinking
    
begin
    
    -- Components bindings
    control_unit : controlunit
        port map (
            clock   => CLK,
            reset   => SW(0),
            ROLL    => BTN_0_DEBOUNCED,
            HOLD    => BTN_1_DEBOUNCED,
            NEWGAME => BTN_2_DEBOUNCED,
            ENADIE  => ENADIE,
            LDSU    => LDSU,
            LDT1    => LDT1,
            LDT2    => LDT2,
            RSSU    => RSSU,
            RST1    => RST1,
            RST2    => RST2,
            BP1     => BP1,
            CP      => CP,
            FP      => FP,
            DIE1    => DIE1,
            WN      => WN
        );

    data_path : datapath
        port map (
            clock   => CLK,
            reset   => SW(0),
            ENADIE  => ENADIE,
            LDSU    => LDSU,
            LDT1    => LDT1,
            LDT2    => LDT2,
            RSSU    => RSSU,
            RST1    => RST1,
            RST2    => RST2,
            CP      => CP,
            FP      => FP,
            DIGIT0  => DIGIT0,
            DIGIT1  => DIGIT1,
            DIGIT2  => DIGIT2,
            DIGIT3  => DIGIT3,
            LEDDIE  => LED(15 downto 13),
            DIE1    => DIE1,
            WN      => WN
        );
    
    sseg_driver : seven_segment_driver
        generic map (
            size => 20
        )
        port map (
            clock   => CLK,
            reset   => SW(0),
            digit0  => DIGIT1,
            digit1  => DIGIT0,
            digit2  => DIGIT3,
            digit3  => DIGIT2,
            CA      => SSEG_CA,
            AN      => SSEG_AN
        );

    roll_debouncer : debouncer
        generic map (
            counter_size => 23
        )
        port map (
            clock    => CLK,
            reset    => SW(0),
            bouncy   => BTN(0),
            pulse    => open,
            debounced=> BTN_0_DEBOUNCED
        );

    hold_debouncer : debouncer
        generic map (
            counter_size => 23
        )
        port map (
            clock    => CLK,
            reset    => SW(0),
            bouncy   => BTN(1),
            pulse    => open,
            debounced=> BTN_1_DEBOUNCED
        );
    
    newgame_debouncer : debouncer
        generic map (
            counter_size => 23
        )
        port map (
            clock    => CLK,
            reset    => SW(0),
            bouncy   => BTN(2),
            pulse    => open,
            debounced=> BTN_2_DEBOUNCED
        );

    -- Process that handles the LED indication of the current player
    player : process(CP)
    begin
        LED(0) <= '0';
        LED(1) <= '0';

        if CP = '0' then
            LED(1) <= '1';
        else
            LED(0) <= '1';
        end if;
    end process player;

    -- Process that handles the blinking of the LEDs when a player wins
    blinking : process(CLK)
    begin
        blink_scaler <= blink_scaler + 1;

        if rising_edge(CLK) and (WN = '1') then
            if blink_scaler(23) = '0' then
                LED(12 downto 2) <= (others => '0');
            else
                LED(12 downto 2) <= (others => '1');
            end if;
        end if;
    end process blinking;

end architecture behavioral;