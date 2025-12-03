entity main_pig_game is
    port (
        CLK : in std_logic; --! system clock
        BTN : in std_logic_vector(4 downto 0); --! input buttons
        LED : out std_logic_vector(15 downto 0); --! output to 7-segment display segments
        SSEG_AN : out std_logic_vector(3 downto 0)  --! output to 7-segment display anodes
        SSEG_CA : out std_logic_vector(7 downto 0)  --! output to 7-segment display cathodes
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


    begin
    -- Instantiation of components




end architecture behavioral;