-------------------------------------------------------------------------------
-- Entity: pwm_led_ctrl
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: (ECS Uebung 8)
-- Synchronization and Debouncing for "PWM_LED"
-------------------------------------------------------------------------------
-- Total # of FFs: 10 + 50 + 3 = 63
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_led_ctrl is
  generic(
    CLK_FRQ : integer
    );
  port(
    rst_pi      : in  std_logic;
    clk_pi      : in  std_logic;
    enc_pi      : in  std_logic_vector(1 downto 0);                
    act_pi      : in  std_logic_vector(2 downto 0);
    incr_evt_po : out std_logic;
    decr_evt_po : out std_logic;
    act_r_po    : out std_logic;
    act_g_po    : out std_logic;
    act_b_po    : out std_logic
    );
end pwm_led_ctrl;

architecture rtl of pwm_led_ctrl is

  -- timer constants 
  -- 1/25 sec = CLK_FRQ / 25 = 40 ms
  constant c_blank_time  : unsigned(22 downto 0) := to_unsigned(CLK_FRQ/25-1, 23); 
  -- synchronization signals (generated in process P1)
  type   t_sync_ar is array (0 to 1) of std_logic_vector(4 downto 0);
  signal sync_ar : t_sync_ar;
  signal sync_enca, sync_encb  : std_logic;
  -- Encoder debouncing signals (generated in process P2)
  signal enca_cnt, encb_cnt       : unsigned(22 downto 0);
  signal debncd_enca, debncd_encb : std_logic;
  signal deb_enc                  : std_logic_vector(1 downto 0);
  -- FSM state and output signals (generated in processes P4/P5)
  type   state is (s_0, s_1, s_2, s_3, s_start);
  signal c_st, n_st : state;
  signal left_evt, right_evt : std_logic;

begin

  -- output assignments
  incr_evt_po <= right_evt;
  decr_evt_po <= left_evt;

  -----------------------------------------------------------------------------
  -- sequential process: Synchronization of encoder and switch inputs
  -- # of FFs: 10
  -----------------------------------------------------------------------------
  P1_sync : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      sync_ar <= (others => (others => '0'));
    elsif rising_edge(clk_pi) then
      -- first stage sync FFs
      sync_ar(0) <= (act_pi(2) & act_pi(1) & act_pi(0) & enc_pi(1) & enc_pi(0)); 
      -- second stage sync FFs
      sync_ar(1) <= sync_ar(0);
    end if;
  end process;
  act_r_po  <= sync_ar(1)(4);
  act_g_po  <= sync_ar(1)(3);
  act_b_po  <= sync_ar(1)(2);
  sync_enca <= sync_ar(1)(1);
  sync_encb <= sync_ar(1)(0);

  -----------------------------------------------------------------------------
  -- sequential process: Debouncing (blanking) of encoder inputs
  -- # of FFs: 23 + 23 + 1 + 1 + 2 = 50
  -----------------------------------------------------------------------------
  P2_deb_enc : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      enca_cnt    <= (others => '0');
      encb_cnt    <= (others => '0');
      debncd_enca <= '0';
      debncd_encb <= '0';
      deb_enc     <= (others => '0');
    elsif rising_edge(clk_pi) then
      -- Debouncing ENC_A (blanking) ---------------------------
      if (enca_cnt = 0) and (sync_enca /= debncd_enca) then 
        -- input changed: start blank time counter
        enca_cnt    <= enca_cnt + 1;
        debncd_enca <= sync_enca;
      elsif enca_cnt > 0 and enca_cnt < c_blank_time then
        -- blank time counter active
        enca_cnt <= enca_cnt + 1;
      else
        -- end of blank time: reset counter
        enca_cnt <= (others => '0');
      end if;
      -- Debouncing ENC_B (blanking) ---------------------------
      if (encb_cnt = 0) and (sync_encb /= debncd_encb) then 
        -- input changed: start blank time counter
        encb_cnt    <= encb_cnt + 1;
        debncd_encb <= sync_encb;
      elsif encb_cnt > 0 and encb_cnt < c_blank_time then
        -- blank time counter active
        encb_cnt <= encb_cnt + 1;
      else
        -- end of blank time: reset counter
        encb_cnt <= (others => '0');
      end if;
      -- combine to 2-bit debounced encoder input --------------
      deb_enc <= debncd_enca & debncd_encb;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- FSM: Mealy-type
  -- Inputs : deb_enc
  -- Outputs: left_evt, right_evt
  -----------------------------------------------------------------------------
  -- memoryless process
  P4_fsm_com : process (c_st, deb_enc)
  begin
    -- default assignments
    n_st      <= c_st; -- remain in current state
    left_evt  <= '0';  -- no left click
    right_evt <= '0';  -- no rightt click
    -- specific assignments
    case c_st is
      when s_start =>
        case deb_enc is
          when "00"   => n_st <= s_0;
          when "01"   => n_st <= s_3;
          when "10"   => n_st <= s_1;
          when others => n_st <= s_2;
        end case;
      when s_0 =>
        case deb_enc is
          when "01"   => n_st <= s_3; 
          when "10"   => n_st <= s_1; 
          when others => null;
        end case;
      when s_1 =>
        case deb_enc is
          when "00"   => n_st <= s_0; left_evt <= '1';
          when "11"   => n_st <= s_2; 
          when others => null;
        end case;
      when s_2 =>
        case deb_enc is
          when "10"   => n_st <= s_1; 
          when "01"   => n_st <= s_3; 
          when others => null;
        end case;
      when s_3 =>
        case deb_enc is
          when "11"   => n_st <= s_2; 
          when "00"   => n_st <= s_0; right_evt <= '1';
          when others => null;
        end case;        
      when others =>
        n_st <= s_start; -- handle parasitic states
    end case;
  end process;
  ----------------------------------------------------------------------------- 
  -- FSM memorizing process
  -- # of FFs: 3 (assuming binary state encoding)
  -----------------------------------------------------------------------------
  P5_fsm_seq : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      c_st <= s_start;
    elsif rising_edge(clk_pi) then
      c_st <= n_st;
    end if;
  end process;
  
end rtl;
