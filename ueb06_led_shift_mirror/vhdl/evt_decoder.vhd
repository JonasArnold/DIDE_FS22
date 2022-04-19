-------------------------------------------------------------------------------
-- Entity : evt_decoder
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 6)
-- Decode debounced rotary encoder signals into left/right-click event signals.
-- Generate button-pressed event signal from debounced button input (active-low).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity evt_decoder is
  port(
    rst_pi      : in  std_logic;
    clk_pi      : in  std_logic;
    enca_deb_pi : in  std_logic;
    encb_deb_pi : in  std_logic;
    butt_deb_pi : in  std_logic; 
    left_evt_po : out std_logic;
    rght_evt_po : out std_logic;
    mirr_evt_po : out std_logic
    );
end evt_decoder;

architecture rtl of evt_decoder is

    signal lst_btn_sync : std_logic;   -- storage for last button state
    
    -- state machine
    type state is (S_rst, S_00, S_01, S_10, S_11);
    signal c_st, n_st : state;
    
begin      
    -- memoryless process MEALY FSM
    p_com: process (c_st, enca_deb_pi, encb_deb_pi)
    begin
        -- default assignments
        n_st <= c_st;  -- remain in current state
        left_evt_po <= '0';
        rght_evt_po <= '0';
        
        -- specific assignments
        case c_st is
            when S_rst =>
                if      enca_deb_pi = '0' and encb_deb_pi = '0' then n_st <= S_00;
                elsif   enca_deb_pi = '0' and encb_deb_pi = '1' then n_st <= S_01;
                elsif   enca_deb_pi = '1' and encb_deb_pi = '0' then n_st <= S_10;
                elsif   enca_deb_pi = '1' and encb_deb_pi = '1' then n_st <= S_11;
                end if;
            when S_00 =>
                if      enca_deb_pi = '0' and encb_deb_pi = '1' then n_st <= S_01;
                elsif   enca_deb_pi = '1' and encb_deb_pi = '0' then n_st <= S_10;
                end if;
            when S_01 =>
                if      enca_deb_pi = '1' and encb_deb_pi = '1' then left_evt_po <= '1'; n_st <= S_11;
                elsif   enca_deb_pi = '0' and encb_deb_pi = '0' then n_st <= S_00;
                end if;
            when S_10 =>
                if      enca_deb_pi = '1' and encb_deb_pi = '1' then rght_evt_po <= '1' ; n_st <= S_11;
                elsif   enca_deb_pi = '0' and encb_deb_pi = '0' then n_st <= S_00;
                end if;
            when S_11 =>
                if      enca_deb_pi = '0' and encb_deb_pi = '1' then n_st <= S_01;
                elsif   enca_deb_pi = '1' and encb_deb_pi = '0' then n_st <= S_10;
                end if;
            when others => 
                n_st <= S_rst; -- handle parasitic state
        end case;

    end process;
    
    -- memorizing process MEALY FSM
    p_seq: process (rst_pi, clk_pi)
    begin
        -- default assignments
        mirr_evt_po <= '0';
        
        if rst_pi = '1' then
            c_st <= S_rst;
            lst_btn_sync <= '1';
        elsif rising_edge(clk_pi) then
            c_st <= n_st;
            -- check if the button state has changed
            if lst_btn_sync = not butt_deb_pi then
                lst_btn_sync <= butt_deb_pi;
                -- button was pressed
                if butt_deb_pi = '0' then
                    mirr_evt_po <= '1';
                end if;
            end if;
        end if;
    end process;
    
end rtl;


