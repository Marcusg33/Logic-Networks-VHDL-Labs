library ieee;
use ieee.std_logic_1164.all;

entity Parking_Controller is
    generic (
        PARKING_CAPACITY : integer := 7
    );
    port (
        -- Clock and Reset
        clk : in std_logic;
        nrst : in std_logic;
        -- Entry Gate 1 Sensors
        sensor_A_Gin1 : in std_logic; -- Before barrier
        sensor_B_Gin1 : in std_logic; -- After barrier
        -- Entry Gate 2 Sensors
        sensor_A_Gin2 : in std_logic;
        sensor_B_Gin2 : in std_logic;
        -- Exit Gate 1 Sensors
        sensor_A_Gout1 : in std_logic;
        sensor_B_Gout1 : in std_logic;
        -- Exit Gate 2 Sensors
        sensor_A_Gout2 : in std_logic;
        sensor_B_Gout2 : in std_logic;
        -- Payment Interface
        payment_done : in std_logic;
        payment_accepted : out std_logic;
        payment_request : out std_logic;
        -- Barrier Controls
        barrier_Gin1 : out std_logic; -- '1' = open
        barrier_Gin2 : out std_logic;
        barrier_Gout1 : out std_logic;
        barrier_Gout2 : out std_logic;
        -- Visual Indicators
        Green_Light : out std_logic;
        Red_Light : out std_logic;
        display : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Behavioral of Parking_Controller is

    -- Components Declaration
    component Gin_fsm is
        port(
            clk         : in  std_logic;
            nrst         : in  std_logic;
            sensor_A_Gin   : in std_logic;
            sensor_B_Gin   : in std_logic;
            enable      : in std_logic;
            car_detected: out std_logic;
            car_entered : out std_logic;
            barrier     : out std_logic
        );
    end component Gin_fsm;
    -- Gout

    component Gout_fsm is
        port(
            clk         : in  std_logic;
            nrst         : in  std_logic;
            sensor_A_Gout   : in std_logic;
            sensor_B_Gout   : in std_logic;
            payment_done : in std_logic;
            payment_request : out std_logic;
            payment_accepted : out std_logic;
            barrier     : out std_logic;
            car_exited : out std_logic
        );
    end component Gout_fsm;

    signal car_count : integer range 0 to PARKING_CAPACITY := 0; -- Car counter
    signal car_detected_Gin1, car_detected_Gin2 : std_logic; -- Car detection flags for entry gates
    signal car_entered_Gin1, car_entered_Gin2 : std_logic; -- Car entered flags for entry gates
    signal car_exited_Gout1, car_exited_Gout2 : std_logic; -- Car exited flags for exit gates
    signal enable_Gin1, enable_Gin2 : std_logic; -- Enable signals for entry gates
    signal payment_requested_Gin1, payment_requested_Gin2 : std_logic; -- Payment request flags for exit gates
    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic; -- Payment accepted flags for exit gates

    type state_type is (IDLE, ENABLE_BOTH, EN_GIN1, EN_GIN2, ERROR_STATE); -- States for parking controller
    signal current_state : state_type := IDLE; -- Current state signal

    function int_to_7seg(value : integer) return std_logic_vector is
        variable result : std_logic_vector(6 downto 0);
    begin
        case value is
            when 0 => result := "0000001"; -- Display '0'
            when 1 => result := "1001111"; -- Display '1'
            when 2 => result := "0010010"; -- Display '2'
            when 3 => result := "0000110"; -- Display '3'
            when 4 => result := "1001100"; -- Display '4'
            when 5 => result := "0100100"; -- Display '5'
            when 6 => result := "0100000"; -- Display '6'
            when 7 => result := "0001111"; -- Display '7'
            when others => result := "1111111"; -- Error
        end case;
        return result;
    end function;

begin

    -- Components port mapping
    Gin1 : Gin_fsm
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A_Gin => sensor_A_Gin1,
            sensor_B_Gin => sensor_B_Gin1,
            enable => enable_Gin1,
            car_detected => car_detected_Gin1,
            car_entered => car_entered_Gin1,
            barrier => barrier_Gin1
        );
    
    Gin2 : Gin_fsm
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A_Gin => sensor_A_Gin2,
            sensor_B_Gin => sensor_B_Gin2,
            enable => enable_Gin2,
            car_detected => car_detected_Gin2,
            car_entered => car_entered_Gin2,
            barrier => barrier_Gin2
        );
        
    Gout1 : Gout_fsm
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A_Gout => sensor_A_Gout1,
            sensor_B_Gout => sensor_B_Gout1,
            payment_done => payment_done,
            payment_request => payment_requested_Gin1,
            payment_accepted => payment_accepted_Gout1,
            barrier => barrier_Gout1,
            car_exited => car_exited_Gout1
        );

    Gout2 : Gout_fsm
        port map (
            clk => clk,
            nrst => nrst,
            sensor_A_Gout => sensor_A_Gout2,
            sensor_B_Gout => sensor_B_Gout2,
            payment_done => payment_done,
            payment_request => payment_requested_Gin2,
            payment_accepted => payment_accepted_Gout2,
            barrier => barrier_Gout2,
            car_exited => car_exited_Gout2
        );


    -- Car Detection Logic for Entry Gates
    in_gate_controller : process(clk, nrst) 
    begin
        -- Reset condition
        if nrst = '0' then
            current_state <= IDLE;

        elsif rising_edge(clk) then
            current_state <= IDLE; -- Default state

            case current_state is
                when IDLE => 
                    if car_detected_Gin1 = '1' and car_detected_Gin2 = '1' then -- Manages two cars simultaneously
                        if car_count < PARKING_CAPACITY - 1 then
                            current_state <= ENABLE_BOTH;
                        else 
                            current_state <= EN_GIN1; -- Prioritizes one gate if nearly full
                        end if;
                    
                    -- Single gate car detection
                    elsif car_detected_Gin1 = '1' and car_count < PARKING_CAPACITY then
                        current_state <= EN_GIN1;
                    elsif car_detected_Gin2 = '1' and car_count < PARKING_CAPACITY then
                        current_state <= EN_GIN2;
                    end if;

                when ERROR_STATE =>
                    -- Block all system until reset
                    current_state <= ERROR_STATE;

                when others =>
                    -- Other states return to IDLE after 1 cycle
                    current_state <= IDLE;
            end case;

        end if;
    end process in_gate_controller;


    -- Output Control based on State
    output_control : process(clk, nrst)
    begin
        if nrst = '0' then
            enable_Gin1 <= '0';
            enable_Gin2 <= '0';

        elsif rising_edge(clk) then
            -- Default disable both gates
            enable_Gin1 <= '0';
            enable_Gin2 <= '0';

            case current_state is
                when ENABLE_BOTH =>
                    enable_Gin1 <= '1';
                    enable_Gin2 <= '1';

                when EN_GIN1 =>
                    enable_Gin1 <= '1';

                when EN_GIN2 =>
                    enable_Gin2 <= '1';

                when others =>
                    null;
            end case;
        end if;
    end process output_control;

    
    -- Counter update process
    counter_process : process(clk, nrst)
    begin
        if nrst = '0' then
            car_count <= 0;

        elsif rising_edge(clk) then
            if car_entered_Gin1 = '1' and car_entered_Gin2 = '1' then -- Two cars enter at the same time (there is no need to check capacity here as it is handled inside in_gate_controller process)
                car_count <= car_count + 2;
            elsif car_entered_Gin1 = '1' or car_entered_Gin2 = '1' then -- One car enters
                car_count <= car_count + 1;
            end if; 

            if car_exited_Gout1 = '1' and car_exited_Gout2 = '1' then -- Two cars exit at the same time
                car_count <= car_count - 2;
            elsif car_exited_Gout1 = '1' or car_exited_Gout2 = '1' then -- One car exits
                car_count <= car_count - 1;
            end if;
        end if;
    end process counter_process;


    -- LED Control Process
    LED_process : process(clk, nrst)
    begin
        if nrst = '0' then
            Green_Light <= '1';
            Red_Light <= '0';

        elsif rising_edge(clk) then
            if car_count < PARKING_CAPACITY then
                Green_Light <= '1';
                Red_Light <= '0';
            else
                Green_Light <= '0';
                Red_Light <= '1';
            end if;
        end if;
    end process LED_process;


    -- 7-Segment Display Update Process
    display_process : process(clk, nrst)
    begin
        if nrst = '0' or rising_edge(clk) then
            display <= int_to_7seg(PARKING_CAPACITY - car_count);
        end if;
    end process display_process;


    -- Payment Processing Logic
    payment_process : process(clk, nrst)
    begin
        if nrst = '0' then
            payment_accepted <= '0';
            payment_request <= '0';

        elsif rising_edge(clk) then
            if payment_requested_Gin1 = '1' or payment_requested_Gin2 = '1' then -- Any exit gate triggers a payment request
                payment_request <= '1';
            else 
                payment_request <= '0';
            end if;

            if payment_accepted_Gout1 = '1' or payment_accepted_Gout2 = '1' then -- Any exit gate triggers a payment acceptance
                payment_accepted <= '1';
            else
                payment_accepted <= '0';
            end if;

        end if;
    end process payment_process;


end architecture Behavioral;