-------------------------------------------------------------------------------
-- Entity : led_display
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- Shifts and mirrows LED pattern according to input events.
-- Shifting stops, if exactly one LED is active in either the left- or right-
-- most position. If both shift and mirrow events appear in the same cc, first
-- shifting and then mirrowing is performed.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_display is
  port(
    rst_pi      : in  std_logic; 
    clk_pi      : in  std_logic;
    left_evt_pi : in  std_logic;
    rght_evt_pi : in  std_logic;
    mirr_evt_pi : in  std_logic;
    led_po      : out std_logic_vector(7 downto 0)
    );
end led_display;

architecture rtl of led_display is

    signal shift : integer := 0;  -- shift value 
    constant c_pattern : std_logic_vector(7 downto 0) := "00111100";

begin

    -- synchronized process to handle events
    p_seq: process(rst_pi, clk_pi)
    begin
        -- reset
        if rst_pi = '1' then
            shift <= 0;
            led_po <= c_pattern;  -- default pattern
            
        -- clock edge
        elsif rising_edge(clk_pi) then
            -- default assignment (only planned in event queue)
            led_po <= "00000000";
        
            -- check if shifted, limit range
            if left_evt_pi = '1' and shift <= (c_pattern'length/2) then
                shift <= shift + 1;
            elsif rght_evt_pi = '1' and shift >= -(c_pattern'length/2) then
                shift <= shift - 1;
            end if;
            
            -- mirror if triggered (overwrites previous calculation)
            if mirr_evt_pi = '1' then 
                shift <= -1 * shift;
            end if;
            
            -- setting led_po to the shifted pattern
            if shift < 0 then  -- shift right
               led_po(7-abs(shift) downto 0) <= c_pattern(7 downto abs(shift));
            else  -- shift left
               led_po(7 downto abs(shift)) <= c_pattern(7-abs(shift) downto 0);
            end if;
        end if;
    
    end process;
end rtl;


