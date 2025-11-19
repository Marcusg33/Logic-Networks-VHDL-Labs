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
    -- State machine types
    type gate_state_type is (IDLE, CAR_DETECTED, CAR_ENTERING, CAR_ENTERED);
    type exit_state_type is (IDLE, WAIT_PAYMENT, PAYMENT_OK,
    CAR_EXITING, CAR_EXITED);
    -- State signals for each gate
    signal state_Gin1, next_state_Gin1 : gate_state_type;
    signal state_Gin2, next_state_Gin2 : gate_state_type;
    signal state_Gout1, next_state_Gout1 : exit_state_type;
    signal state_Gout2, next_state_Gout2 : exit_state_type;
    -- Car counter
    signal car_count : integer range 0 to PARKING_CAPACITY := 0;
    -- Edge detection for sensors
    signal sensor_A_Gin1_prev, sensor_B_Gin1_prev : std_logic;
    -- ... (add for other gates)
    -- Increment/decrement flags
    signal inc_Gin1, inc_Gin2 : std_logic;
    signal dec_Gout1, dec_Gout2 : std_logic;
    -- Payment signals
    signal payment_accepted_Gout1, payment_accepted_Gout2 : std_logic;
begin

stateregister: process(clk, nrst)
    begin
    if nrst = '0' then
        -- Reset all states to IDLE
        state_Gin1 <= IDLE;
        state_Gin2 <= IDLE;
        state_Gout1 <= IDLE;
        state_Gout2 <= IDLE;
        -- Reset sensor history
        sensor_A_Gin1_prev <= '0';
        sensor_B_Gin1_prev <= '0';
        -- ... (reset others)
    elsif rising_edge(clk) then
        -- Update states
        state_Gin1 <= next_state_Gin1;
        -- ... (update others)
        -- Store sensor values for edge detection
        sensor_A_Gin1_prev <= sensor_A_Gin1;
        -- ... (store others)
    end if;
end process;

gin1: process(state_Gin1, sensor_A_Gin1, sensor_B_Gin1,
sensor_A_Gin1_prev, sensor_B_Gin1_prev, car_count)
    begin
    -- Default values
    next_state_Gin1 <= state_Gin1;
    barrier_Gin1 <= '0';
    inc_Gin1 <= '0';
    case state_Gin1 is
        when IDLE =>
            -- Check for car arrival and capacity
            if sensor_A_Gin1 = '1' and car_count < PARKING_CAPACITY then
                next_state_Gin1 <= CAR_DETECTED;
            end if;
        when CAR_DETECTED =>
            -- TODO: Implement transitions
            -- - Back to IDLE if car leaves
            -- - To CAR_ENTERING if sensor B triggered
        when CAR_ENTERING =>
            barrier_Gin1 <= '1'; -- Keep barrier open
            -- TODO: Implement transitions
            -- - To CAR_ENTERED when car fully inside
            -- - Handle reverse scenario
        when CAR_ENTERED =>
            barrier_Gin1 <= '1';
            -- TODO: Implement transition back to IDLE
            -- Set inc_Gin1 to increment counter
    end case;
end process;

gout1: process(state_Gout1, sensor_A_Gout1, sensor_B_Gout1,
payment_done, car_count)
    begin
    -- Default values
    next_state_Gout1 <= state_Gout1;
    barrier_Gout1 <= '0';
    payment_request <= '0';
    payment_accepted_Gout1 <= '0';
    dec_Gout1 <= '0';
    case state_Gout1 is
        when IDLE =>
            -- TODO: Detect car and check if parking has cars
        when WAIT_PAYMENT =>
            payment_request <= '1'; -- Turn on payment light
            -- TODO: Wait for payment or car to leave
        when PAYMENT_OK =>
            payment_accepted_Gout1 <= '1';
            -- TODO: Wait for car to start exiting
        when CAR_EXITING =>
            barrier_Gout1 <= '1';
            -- TODO: Detect when car fully exits
        when CAR_EXITED =>
            barrier_Gout1 <= '1';
            -- TODO: Return to IDLE and decrement counter
    end case;
end process;

countermgt: process(clk, nrst)
begin
    if nrst = '0' then
        car_count <= 0;
    elsif rising_edge(clk) then
        if inc_Gin1 = '1' then
            car_count <= car_count + 1;
        elsif inc_Gin2 = '1' then
            car_count <= car_count + 1;
        -- Handle decrements from exit gates
        elsif dec_Gout1 = '1' then
            car_count <= car_count - 1;
        elsif dec_Gout2 = '1' then
            car_count <= car_count - 1;
        end if;
    end if;
end process;

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
-- Display available spots
display <= int_to_7seg(PARKING_CAPACITY - car_count);
-- Control indicator lights
Green_Light <= '1' when car_count < PARKING_CAPACITY else '0';
Red_Light <= '1' when car_count = PARKING_CAPACITY else '0';
-- Payment accepted from either exit gate
payment_accepted <= payment_accepted_Gout1 or payment_accepted_Gout2;