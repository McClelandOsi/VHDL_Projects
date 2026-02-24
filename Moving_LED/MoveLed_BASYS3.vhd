----------------------------------------------------------------------------------
-- Name: MoveLed_BASYS3 
-- Designer: McCleland Idaewor 
-- 
-- wrapper file for the MoveLed component. This wrapper 
-- is targeting the Basys3 board from Digilent. The configuration file 
-- for the Basys3 was retrieved from the digilent GitHub account.
--
--  The right and left buttons move a single led across the board, when
--  the center button is pressed, the led will do back to the starting 
--  position which is led00 on the board
----------------------------------------------------------------------------------
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MoveLed_BASYS3 is
 Port ( btnL      : in std_logic; --button that moves LED to the right
        btnR      : in std_logic; --button that moves LED to the right
        btnC      : in std_logic; --reset button
        clk       : in std_logic; --100MHz clock
        led       : out std_logic_vector(15 downto 0); --16 LEDs
        seg       : out std_logic_vector(6 downto 0);  --7-seg display
        an        : out std_logic_vector(3 downto 0)); --4-digit enable
end MoveLed_BASYS3;


architecture MoveLed_BASYS3_ARCH of MoveLed_BASYS3 is

    component MoveLed
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            moveLeft  : in std_logic;
            moveRight : in std_logic;
            led_pos   : out std_logic_vector(3 downto 0);
            leds      : out std_logic_vector(15 downto 0));
    end component;
    
    --Internal signals---------------------------------------------
    signal led_pos       : std_logic_vector(3 downto 0);
    signal debounceL     : std_logic := '0';
    signal debounceR     : std_logic := '0';
    signal slow_clk      : std_logic := '0';
    signal clk_counter   : unsigned(19 downto 0) := (others => '0');

    --For 7-segment display-----------------
    signal hex_seg       : std_logic_vector(6 downto 0);
    signal dec_tens_seg  : std_logic_vector(6 downto 0);
    signal dec_ones_seg  : std_logic_vector(6 downto 0);
    signal blank_seg     : std_logic_vector(6 downto 0) := "1111111";     
    
begin
      --clock for the whole design--------------------
      SYSTEM_CLOCK: process (clk)
      begin
          ----clock divider-----------------
          if rising_edge(clk) then
             clk_counter <= clk_counter + 1;
             slow_clk <= clk_counter(17); -- debounces every 1.31 ms
           end if;
      end process;
      
      --left button debounce-------------------------------------------------  
       LEFT_DEBOUNCE: process (slow_clk)
         variable btnL_sync : std_logic_vector(1 downto 0) := (others => '0');
       begin
          if rising_edge(slow_clk) then
             btnL_sync := btnL_sync(0) & btnL;  
             if btnL_sync = "11" then
                 debounceL <= '1';
             else
                 debounceL <= '0';
             end if;
          end if;
       end process;    
       
       --right button debounce-----------------------------------------------        
       RIGHT_DEBOUNCE: process (slow_clk)
          variable btnR_sync : std_logic_vector(1 downto 0) := (others => '0');
       begin
          if rising_edge(slow_clk) then
             btnR_sync := btnR_sync(0) & btnR;  
             if btnR_sync = "11" then
                 debounceR <= '1';
             else
                 debounceR <= '0';
             end if;
          end if;
       end process;         
      
     UUT: MoveLed port map (
            clk       => clk,
            reset     => btnC,
            moveLeft  => debounceL,
            moveRight => debounceR,
            led_pos   => led_pos,
            leds      => led
        ); 

     --7 segment display--------------------------------------------
     DISPLAY_DRIVER: process (led_pos)
        variable dec_val : integer;
        variable tens    : integer;
        variable ones    : integer;
        
     begin
        --decimal value logic-------------------
        dec_val := to_integer(unsigned(led_pos));
        tens := dec_val / 10;
        ones := dec_val mod 10;
        
        --HEX display for left digit----------------------
         case led_pos is
             when "0000" => hex_seg <= "1000000"; -- 0
             when "0001" => hex_seg <= "1111001"; -- 1
             when "0010" => hex_seg <= "0100100"; -- 2
             when "0011" => hex_seg <= "0110000"; -- 3
             when "0100" => hex_seg <= "0011001"; -- 4
             when "0101" => hex_seg <= "0010010"; -- 5
             when "0110" => hex_seg <= "0000010"; -- 6
             when "0111" => hex_seg <= "1111000"; -- 7
             when "1000" => hex_seg <= "0000000"; -- 8
             when "1001" => hex_seg <= "0010000"; -- 9
             when "1010" => hex_seg <= "0001000"; -- A
             when "1011" => hex_seg <= "0000011"; -- b
             when "1100" => hex_seg <= "1000110"; -- C
             when "1101" => hex_seg <= "0100001"; -- d
             when "1110" => hex_seg <= "0000110"; -- E
             when others => hex_seg <= "0001110"; -- F
         end case;
        
        --Tens place for the decimal display---------
         case tens is
             when 0 => dec_tens_seg <= "1000000";
             when 1 => dec_tens_seg <= "1111001";
             when others => dec_tens_seg <= "1111111";
         end case;    
        
        --Ones place for the decimal display---------
         case ones is
             when 0 => dec_ones_seg <= "1000000";
             when 1 => dec_ones_seg <= "1111001";
             when 2 => dec_ones_seg <= "0100100";
             when 3 => dec_ones_seg <= "0110000";
             when 4 => dec_ones_seg <= "0011001";
             when 5 => dec_ones_seg <= "0010010";
             when 6 => dec_ones_seg <= "0000010";
             when 7 => dec_ones_seg <= "1111000";
             when 8 => dec_ones_seg <= "0000000";
             when 9 => dec_ones_seg <= "0010000";
             when others => dec_ones_seg <= "1111111";
         end case;      
     end process;      
     
     --display multiplexer------------------------------------
     process (clk_counter)
          begin
            case clk_counter(18 downto 17) is
                when "00" =>
                     an <= "0111"; seg <= hex_seg;--leftmost HEX
                when "01" =>
                     an <= "1011"; seg <= blank_seg;--blank digit
                when "10" =>
                     an <= "1101"; seg <= dec_tens_seg;--decimal tens
                when others =>
                     an <= "1110"; seg <= dec_ones_seg;--decimal ones
            end case;
     end process;
