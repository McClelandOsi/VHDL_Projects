--==============================================================
--Rotary encoder Single LED
--Cynthia Babecka and McCleland Idaewor
--
-- This design takes the input from the Pmod encoder, filters
-- it to drive the led position
--
--==============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Encoder is
      Port (
            A:in std_logic;
            B: in std_logic;
            led: out std_logic_vector(15 downto 0);
            rotaryBtn: in std_logic;
            clock: in std_logic;
            reset: in std_logic;
            
            --seven seg outpus-----------
            speed    : out integer;
            degree   : out integer;
            negative : out std_logic          
            );
end Encoder;

architecture Encoder_ARCH of Encoder is

--Encoder_Decoder----------------------------------------------
signal leftCount: integer := 0;
signal rightCount: integer := 0;
signal rightPulse: std_logic;
signal leftPulse: std_logic;
signal ledPosition: integer := 0;
signal currentState: std_logic_vector (1 downto 0);
signal pastState: std_logic_vector(1 downto 0);
constant ACTIVE: std_logic := '1';
signal A_sync, B_sync : std_logic_vector(1 downto 0); 
signal turn_count: integer;
signal inNegative: std_logic; --input for seven seg

--Mode_Switch--------------------------------------------------
signal change: std_logic;
signal modeNum: integer;

--State--------------------------------------------------------
type State_t is (RPM, ANGLE);
signal nextState: State_t;
signal presentState: State_t;
signal inDegree: integer;--input for seven seg
signal inSpeed: integer; --input for seven seg

--Second-------------------------------------------------------
signal oneSecond: std_logic;

--------------------------------------------------------------- 
begin
     --=========================================================
     -- Filter AB inputs to etect direction and generate
     -- left/right pulses
     --=========================================================
     ENCODER_DECODER: process (clock, reset)
     begin
          if (reset = ACTIVE) then
              A_sync <= (others => '0');
              B_sync <= (others => '0');
              currentState <= "00";
              pastState <= "00";
              rightPulse <= '0';
              leftPulse  <= '0';
              turn_count <= 0;
              inNegative <= '0';
                            
          elsif (rising_edge(clock)) then
              A_sync(0) <= A;
              A_sync(1) <= A_sync(0);
              B_sync(0) <= B;
              B_sync(1) <= B_sync(0);
              currentState <= A_sync(1) & B_sync(1);
              
              
              if (currentState /= pastState) then
                  case pastState & currentState is
                       when "1101"|"0100"|"0010"|"1011" =>
                            leftCount <= leftCount + 1;
                            turn_count <= turn_count + 1;
                            inNegative <= '0';
                            if (leftCount = 3) then
                                leftPulse <= '1';
                                rightPulse <='0';
                                leftCount <= 0;
                            end if;
                       when "1110"|"1000"| "0001"|"0111" =>
                            rightCount <= rightCount + 1;
                            turn_count <= turn_count - 1;
                            inNegative <= '1';
                            if (rightCount = 3) then
                                leftPulse <='0';
                                rightPulse <='1';
                                rightCount <= 0;
                             end if;
                       when others =>
                            leftPulse <= '0';
                            rightPulse <= '0';
                   end case;
                   pastState <= currentState;
               else
                    leftPulse <= '0';
                    rightPulse <= '0';
              end if;
          end if;
           negative <= inNegative; 
     end process;
     --===========================================================
     --Updates Led positon based on direction pulses
     --===========================================================
     POSITION: process(clock, reset)--component block
     begin 
            if (reset = ACTIVE) then
                 ledPosition <= 0;
            elsif (rising_edge(clock)) then
                  if rightPulse = '1' then
                        if ledPosition = 0 then
                           ledPosition <= 15;
                        else
                            ledPosition <= ledPosition - 1;
                        end if;
                  elsif leftPulse = '1' then
                        if ledPosition = 15 then
                            ledPosition <= 0;
                        else
                            ledPosition <= ledPosition + 1;
                        end if;
                  end if;
            end if;
     end process;
     
     --==========================================================
     --Takes the Led position and in RPM mode turns the 
     --corisponding Led on and all the others off, and in ANGLE 
     --the coriponding led off and all other on. 
     --==========================================================
     LED_DRIVER: process (clock, reset)
     begin
            if (reset = ACTIVE) then
                led <= (others => '0');
                led(0)<= '1';
            elsif(rising_edge(clock)) then
                if (modeNum = 0) then
                    led <= (others => '0');
                    led(ledPosition) <= '1';
                elsif (modeNum = 1) then
                    led <= (others => '1');
                    led(ledPosition) <= '0';
                end if;
            end if;
     end process;
     
     --==========================================================
     --
     --
     --==========================================================
     STATE_REG: process (clock, reset)
     begin
          if (reset = ACTIVE) then
              presentState <= RPM;
          elsif (rising_edge(clock)) then
              presentState <= nextState;
          end if;
     end process;
     
     --==========================================================
     --Transitions the State between RPM and ANGLE depending on
     --the inputofrom the change signal
     --==========================================================
     STATE_TRANS: process(presentState, rotaryBtn, turn_count)
     variable speedUpdate : integer;
     begin
          nextState <= presentState;
          case presentState is
                when RPM =>
                    if (oneSecond = '1') then
                        speedUpdate := turn_count*3;
                       -- turn_count <= 0;
                    end if;
                    inSpeed <= speedUpdate;                    
                    if (change = ACTIVE) then
                        inSpeed <= 0;
                        nextState <= ANGLE;
                    end if;
                    speed <= inSpeed;
                when ANGLE =>
                    inDegree <= turn_count*18;
                    if (change = ACTIVE) then
                        inDegree <= 0;
                        nextState <= RPM;
                    end if;
                    degree <= inDegree;
          end case;
      end process;
      
      --==========================================================
      --Reads the input of the roatary button to change the state
      --and led mode
      --==========================================================
      Mode_Switch: process(clock, reset)
      begin
           if (reset = ACTIVE) then
                modeNum <= 0;
           elsif (rising_edge(clock)) then
                if (rotaryBtn = ACTIVE) then
                    modeNum <= modeNum + 1;
                    if (modeNum = 1) then modeNum <= 0; end if;
                    change <= '1';
               -- elsif (rotaryButton = not Active) then
                 --   modeNum <= modeNum;
                end if;
          end if;
      end process;
      
      --==========================================================
      --One second timer to drive the rpm calculations
      --==========================================================
      Second_Timer: process (clock)
      variable counter: integer;
      begin
            if (reset = ACTIVE) then
                oneSecond <= '0';
                counter := 0;
            elsif (rising_edge(clock)) then
                if (counter = 999_999_999)then 
                    counter := 0;
                    oneSecond <= '1';
                else 
                    counter := counter +1;
                    oneSecond <= '0';
                end if;
            end if;
     end process;
     
        
      
                 