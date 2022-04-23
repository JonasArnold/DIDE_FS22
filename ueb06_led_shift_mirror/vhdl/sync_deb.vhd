-------------------------------------------------------------------------------
-- Entity : sync_deb
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (DIDE Uebung 6)
-- Synchroniration and debouncing (blanking) of asynchronous single-bit signal.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_deb is
  generic(
    CLK_FRQ : integer := 125_000_000 -- 125 MHz = 0x7735940 (27 bits)
    );
  port(
    rst_pi   : in  std_logic;
    clk_pi   : in  std_logic;
    async_pi : in  std_logic;
    deb_po   : out std_logic
    );
end sync_deb;

architecture rtl of sync_deb is

    -- 20 ms = CLK_FRQ / 50
    constant c_blank_time : unsigned(26 downto 0) := to_unsigned(CLK_FRQ/50-1,27); 
    
    signal enb : std_logic;                     -- edge detected flag
    signal sync : std_logic_vector(3 downto 0); -- internal sync array
    signal deb_cnt : unsigned(26 downto 0);     -- counter for debounce time
    signal blank_state : std_logic := '0';      -- flag to set when blank time is waited for
    signal blank_signal : std_logic;            -- signal that shall be output during blank dime
    
    ------------------------------------
begin    
    -- sequential process for synchronizing, recognize rising and falling edge
    enb <= (sync(3) and not sync(2)); --rising edge -- or (sync(3) and not sync(2))  -- falling edge;
    p_sync: process (rst_pi, clk_pi)
    begin
      if rst_pi = '1' then
        sync <= "0000";
      elsif rising_edge(clk_pi) then
        sync(0) <= async_pi;
        sync(1) <= sync(0);
        sync(2) <= sync(1);
        sync(3) <= sync(2);
      end if;
    end process;
    
    --- sequential process for debouncing
    p_blank_deb: process (rst_pi, clk_pi)
    begin
      if rst_pi = '1' then
          --- reset variables
          deb_cnt <= (others => '0');
          blank_state <= '0';
          deb_po <= '0';
          blank_signal <= '0';
           
      elsif rising_edge(clk_pi) then
          -- default assignments
          deb_cnt <= (others => '0');
          blank_state <= '0';
          deb_po <= blank_signal;  -- take signal during blanking
          
          -- check if currently blanking
          if blank_state = '1' then
            if deb_cnt < c_blank_time then
                deb_cnt <= deb_cnt + 1;    -- count up
                blank_state <= '1';        -- stay in blank state 
            end if;          
            
          -- else check if the signal has changed
          elsif enb = '1' then
              deb_cnt <= (others => '0');   -- reset counter
              blank_signal <= sync(2);      -- store signal
              blank_state <= '1';           -- set blank flag (indicate blanking state)
              
          -- if not blanking => set signal
          elsif blank_state = '0' then
              deb_po <= sync(2);
          end if;
      end if;
    end process;
end rtl;


