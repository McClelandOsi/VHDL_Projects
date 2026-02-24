----------------------------------------------------------------------------------
-- Name: MoveLed 
-- Designer: McCleland Idaewor 
-- 
-- This componect is degigned to output a pattern on the leds based
-- on using sequential elements to when when either the right or 
-- left button is pressed, the led moves in that corresponding 
-- direction. There is also a reset button that makes the board
-- go to led00
--
-- To show current postion the seven-segment display the decimal
-- value on the right side and the hexadecimal values on the left
--
--
----------------------------------------------------------------------------------
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MoveLed is
    Port ( clk       : in std_logic; 
           reset     : in std_logic;
           moveLeft  : in std_logic;
           moveRight : in std_logic;
           led_pos   : out std_logic_vector(3 downto 0);
           leds      : out std_logic_vector(15 downto 0));  
end MoveLed;

architecture MoveLed_ARCH of MoveLed is

  ------------------------------------------------------------------
  -- Registers (synchronous state)
  ------------------------------------------------------------------
  signal pos_reg    : unsigned(3 downto 0) := (others => '0');  -- 0 to 15 position
  signal prev_btnL  : std_logic := '0';                         -- previous state of btnL
  signal prev_btnR  : std_logic := '0';                         -- previous state of btnR
  signal btnL_edge  : std_logic;                                -- edge detection
  signal btnR_edge  : std_logic;
  constant ACTIVE   : std_logic := '1';

begin
    LED_POSITION: process(clk,reset)
      
       -- edge detection variable----------------------
       variable btnL_edge_v : std_logic := '0';
       variable btnR_edge_v : std_logic := '0';
    begin
        --reset button-----------------
        if (reset = ACTIVE) then
            pos_reg <= (others => '0');
            prev_btnL <= '0';
            prev_btnR <= '0';
        --Initialize variables each clock cycle------------------------------
        elsif (rising_edge(clk)) then  
            btnL_edge_v := '0'; 
            btnR_edge_v := '0';
            --Detect rising edges on buttons-------------------------------------------------          
            if (moveLeft = '1' and prev_btnL = '0') then  --- left edge
                btnL_edge_v := '1';
            elsif (moveRight = '1' and prev_btnR = '0') then --- right edge
                btnR_edge_v := '1';
            end if;   
            --Move LED position based on edge detection------------------------ 
            if (btnL_edge_v = '1') and (btnR_edge_v = '0') then --- when just the left is pressed
               if (pos_reg > 0) then
                 --Moves the led to the left----------
                 pos_reg <= pos_reg - 1;
               end if;
            elsif (btnR_edge_v = '1') and (btnL_edge_v = '0') then --- when just the right is pressed
               if (pos_reg < 15) then
                 --Moves the led to the right---------
                 pos_reg <= pos_reg + 1;
               end if;
            elsif (btnR_edge_v = '1') and (btnL_edge_v = '1') then --- when both is pressed, right gets priority 
               if (pos_reg < 15) then
                 pos_reg <= pos_reg; --the led stays at it's current position if both buttons are pressed
               end if;  
            end if;   
            
            --Update previous button states--------------------
            prev_btnL <= moveLeft;
            prev_btnR <= moveRight;
             
        end if;
    end process;  
  
    LED_DRIVER: 
      led_pos <= std_logic_vector(pos_reg); --4-bit output for the led position (for display)
      
      --converts the 4-bit to the 16-bit output (for the LEDs)---------------------------
      leds <=  std_logic_vector(to_unsigned(1, 16) sll to_integer(pos_reg)) when reset = '0' else
              (others => '0');         
    
end MoveLed_ARCH;
