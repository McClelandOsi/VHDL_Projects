----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2025 04:38:34 PM
-- Design Name: 
-- Module Name: Encoder_BASYS3 - Encoder_BASYS3_ARCH
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Encoder_BASYS3 is
    Port ( 
         JB       : in std_logic_vector(2 downto 0);
         btnC     : in std_logic;
         clk      : in std_logic;
         led      : out std_logic_vector(15 downto 0); 
         negative : out std_logic;
         speed    : out integer;
         degree   : out integer;
         seg      : out std_logic_vector(7 downto 0);
         an       : out std_logic_vector(3 downto 0)
    );
end Encoder_BASYS3;

architecture Encoder_BASYS3_ARCH of Encoder_BASYS3 is

    component Encoder is
        Port (
              A         : in std_logic;
              B         : in std_logic;
              rotaryBtn : in std_logic;
              led       : out std_logic_vector(15 downto 0);
              clock     : in std_logic;
              neg       : out std_logic;
              degree    : out integer;
              speed     : out integer;
              reset     : in std_logic);
    end component;         
    
    component decimalSeg is
        Port (
        reset: in std_logic;
        clock: in std_logic;
        
        digit3: in std_logic_vector(3 downto 0);
        digit2: in std_logic_vector(3 downto 0);
        digit1: in std_logic_vector(3 downto 0);
        digit0: in std_logic_vector(3 downto 0);
        
        blank3: in std_logic;
        blank2: in std_logic;
        blank1: in std_logic;
        blank0: in std_logic;
         
        decSegs: out std_logic_vector(6 downto 0); 
        anodes:  out std_logic_vector(3 downto 0)
        );
    end component;    
    
    component Debouncer is
        generic(
                DEBOUNCE_COUNT : natural := 100_000  -- 1 ms at 100 MHz
                );
        Port(  clk : in  std_logic;
               --signals from the pmod------
               Ain : in  std_logic; 
               Bin : in  std_logic;
               -- debounced signals--------- 
               Aout: out std_logic;
               Bout: out std_logic
                  );
    end component;
    
    -- -------------------------
    -- Internal signals
    -- -------------------------
    signal A_bounce : std_logic;
    signal B_bounce : std_logic;
    
    -- internal signals to receive Encoder outputs---------
    signal speed_sig    : integer := 0;
    signal degree_sig   : integer := 0;
    signal negative_sig : std_logic := '0';
    signal led_raw : std_logic_vector(15 downto 0);
  
    
        
    --Internal signals for rotaryBTN-----------------------------
    signal btn_sync     : std_logic_vector(1 downto 0) := (others => '0');
    signal btn_prev     : std_logic := '0';
    signal debounceBTN  : std_logic := '0'; 
    
    --Mode toggle----------------------------------------------
    signal show_speed : std_logic := '0';--0 = show speed, 1 = show degree
    
    --Display conversion signals-------------------------------------
    signal number       : integer range -999 to 999 := 0; -- chosen display number
    signal abs_number   : integer range 0 to 999 := 0;
    signal hundreds_i   : integer range 0 to 9 := 0;
    signal tens_i       : integer range 0 to 9 := 0;
    signal ones_i       : integer range 0 to 9 := 0;
    signal sign_needed  : std_logic := '0';
    
    --4-bit digit vectors for decimalSeg-------------------------
    signal digit3, digit2, digit1, digit0 : std_logic_vector(3 downto 0) := (others => '0');
    signal blank3, blank2, blank1, blank0 : std_logic := '0';
    
    --decimalSeg outputs (no DP)------
    signal seg_internal : std_logic_vector(6 downto 0);
    signal an_internal  : std_logic_vector(3 downto 0);
    
    --final led out (after mode-based inversion)------
    signal led_out      : std_logic_vector(15 downto 0);
    
begin
    
   ROTARY_DEBOUNCE: Debouncer
       generic map (
            DEBOUNCE_COUNT => 100_000  -- 1 ms at 100 MHz 
       )
       port map (
                    Ain => JB(0),
                    Bin => JB(1),
                    clk => clk,
                    Aout => A_bounce,
                    Bout => B_bounce);
               
      --rotary button debounce--------------------
    BTN_DEBOUUNCE:  process(clk)
    begin
        if rising_edge(clk) then
            -- two-stage synchronizer
            btn_sync(0) <= JB(2);
            btn_sync(1) <= btn_sync(0);

            -- rising-edge detection -> one-clock pulse
            if (btn_sync(1) = '1' and btn_prev = '0') then
                debounceBTN <= '1';
            else
                debounceBTN <= '0';
            end if;
            
            btn_prev <= btn_sync(1);          
        end if;
    end process;                  
  SEGMENT_U: decimalSeg
      port map (     
                 reset => btnC,
                 clock => clk,
                 
                 digit3 => digit3,
                 digit2 => digit2,
                 digit1 => digit1,
                 digit0 => digit0,
                 
                 blank3 => '0',
                 blank2 => '0',
                 blank1 => '0',
                 blank0 => '0',
                 
                 decSegs => seg_internal,
                 anodes => an_internal);      
                       
  UUT: Encoder
      Port map (
                 A => A_bounce,
                 B => B_bounce,
                 rotaryBtn => debounceBTN,
                 clock => clk,
                 reset => btnC,
                 led => led_raw,
                 neg => negative_sig,
                 degree  => degree_sig,
                 speed   => speed_sig
                );
  
  --Drive entity output ports from internal signals (single driver)--
    negative <= negative_sig;
    speed    <= speed_sig;
    degree   <= degree_sig;
  
    -----------------------------------------------------------------------------
    -- Button-driven mode toggle (press to toggle)
    -----------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if debounceBTN = '1' then
                show_speed <= not show_speed;
            end if;
        end if;
    end process;
  
  -----------------------------------------------------------------------------
    -- Mode-based LED indicator:
    -- speed mode => show led_raw (one LED lit)
    -- degree mode => show inverse of led_raw (all but one lit)
  -----------------------------------------------------------------------------
  LED_DRIVER: process(led_raw, show_speed)
    begin
        if show_speed = '1' then
            led <= led_raw; -- speed mode
        else
            led <= not led_raw; -- angle mode (inverse)
        end if;
    end process;
 
    --drive top port
    led <= led_out;

   --Decide what to display based on toggle state-- 
   with show_speed select
     number <= degree_sig   when '1',
              speed_sig  when others;
              
     
    --Convert integer "number" (range -999 to 999) into sign + hundreds/tens/ones----
    SEG_CONVERT: process(number)
        variable n : integer;
    begin
        if number < 0 then
            n := -number;
            sign_needed <= '1';
        else
            n := number;
            sign_needed <= '0';
        end if;

        if n > 999 then
            -- clamp for overflow display
            n := 999;
        end if;

        abs_number <= n;
        hundreds_i <= (n / 100) mod 10;
        tens_i     <= (n / 10) mod 10;
        ones_i     <= n mod 10;
    end process;
    
     --------------------------------------------------------------------------------
    -- Map the integer digits to 4-bit vectors expected by decimalSeg.
    -- If sign_needed = '1', show minus sign in the leftmost digit (decimalSeg maps "1110" -> minus).
    --------------------------------------------------------------------------------
    digit3 <= "1110" when sign_needed = '1' else std_logic_vector(to_unsigned(hundreds_i,4));
    digit2 <= std_logic_vector(to_unsigned(tens_i,4));
    digit1 <= std_logic_vector(to_unsigned(ones_i,4));
    digit0 <= "0000";  -- unused rightmost digit 

     ----------------------------------------------------------------------------
    -- Blanking policy (decimalSeg uses ACTIVE='1' to BLANK).
    -- Here we blank leading thousands if not needed; keep others visible.
     ----------------------------------------------------------------------------
    blank3 <= '0' when (sign_needed = '1') else   -- show minus if needed
              '1' when (hundreds_i = 0 and tens_i = 0 and ones_i /= 0) else
              '0';  -- default show hundreds 
    blank2 <= '0';
    blank1 <= '0';
    blank0 <= '1';  -- rightmost unused -> blank

    -----------------------------------------------------------------------------
    -- Decimal point (DP) logic:
    -- We assert DP (active-LOW) only while the target digit anode is active.
    -- Requirement:
    --   - RPM mode  -> light far-left decimal point (leftmost digit)
    --   - ANGLE mode -> light far-right decimal point (rightmost digit)
    --
    -- decimalSeg uses active-LOW anodes:
    --   leftmost  => "0111"
    --   rightmost => "1110"
    -----------------------------------------------------------------------------
    
    process(an_internal, show_speed, seg_internal)
    begin
        -- default: DP off (high = inactive, because DP is active-LOW)
        -- build full 8-bit seg output: seg_out(6 downto 0) = seg_internal, seg_out(7)=DP
        -- decide DP based on an_internal active-low value:
        if (show_speed = '1' and an_internal = "0111") then
		
            -- RPM mode & leftmost digit is active -> assert DP (active low)
            seg(7) <= '0';
        
		elsif (show_speed = '0' and an_internal = "1110") then
        
		-- ANGLE mode & rightmost digit is active -> assert DP (active low)
            seg(7) <= '0';

        else

            seg(7) <= '1'; -- DP OFF

        end if;

        -- map the 7 segment bits (g..a) from decimalSeg
        seg(6 downto 0) <= seg_internal;
        
		-- pass through anodes to top port
        an <= an_internal;
    
	end process;

    
end Encoder_BASYS3_ARCH;