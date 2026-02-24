----------------------------------------------------------------------------------
--  Name: Pattern_Led 
-- Designer: McCleland Idaewor 
-- 
--    This component is designed to output a pattern of leds based on which side is enabled based on the assiogned 
--    button and how leds are leds are lit up based on the value given by the combination of switches flipped 
--
--    To show the value of the switches, the seven-segment display will show the valuve of the current flipped switches
--
-- 
-- 
----------------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pattern_Led is
    Port ( leftEn    : in std_logic; -- left Enable button
           rightEn   : in std_logic; -- right Enable button
           numSw     : in std_logic_vector (2 downto 0); -- input switches
           leds      : out std_logic_vector (15 downto 0) -- LED outputs
          );
end Pattern_Led;

architecture Pattern_Led_ARCH of Pattern_Led is
    signal   num     : integer range 0 to 7; 
    signal left_led  : std_logic_vector(15 downto 0) := (others => '0');
    signal right_led : std_logic_vector(15 downto 0) := (others => '0');
begin

 num <= to_integer(unsigned(numSw)); -- converts numSw to intergers

LEFT_DRIVER: process(num) --LED left pattern
     begin  
          case (num) is 
              when 0 => left_led <= (others => '0');
              when 1 => left_led <= "1000000000000000"; 
              when 2 => left_led <= "1100000000000000";
              when 3 => left_led <= "1110000000000000";
              when 4 => left_led <= "1111000000000000";
              when 5 => left_led <= "1111100000000000";
              when 6 => left_led <= "1111110000000000";
              when 7 => left_led <= "1111111000000000";
              when others => left_led <= (others => '0');
           end case;  
    end process;
     
RIGHT_DRIVER: process(num) -- LED right pattern
     begin           
          case (num) is 
              when 0 => right_led <= (others => '0');
              when 1 => right_led <= "0000000000000001"; 
              when 2 => right_led <= "0000000000000011";
              when 3 => right_led <= "0000000000000111";
              when 4 => right_led <= "0000000000001111";
              when 5 => right_led <= "0000000000011111";
              when 6 => right_led <= "0000000000111111";
              when 7 => right_led <= "0000000001111111";
              when others => right_led <= (others => '0');
           end case;       
    end process;

OUT_DRIVER:  process(leftEn, rightEn, left_led, right_led, num) -- output logic: only one side is active
      begin
            if (leftEn = '1') then
                leds <= left_led;
            elsif (rightEn = '1') then
                leds <= right_led;
            else 
                leds <=(others => '0'); -- if both buttons are pressesed, LEDs stay/turn off 
            end if;       
         end process;    

end Pattern_Led_ARCH;