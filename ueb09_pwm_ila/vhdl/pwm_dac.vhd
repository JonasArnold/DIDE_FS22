-------------------------------------------------------------------------------
-- Entity: pwm_dac
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- PWM-DAC with generics for resolution and clock prescaling. The digital input
-- value is converted into a PWM signal. The 2^N possible input values are
-- mapped linearly to PWM duty cycle values as follows:
-- pwm_duty_cycle = (k * 100%)/(2^N-1) with k=0,1,...,2^N-1.
-- The sampling rate = conversion rate of the DAC is given as follows:
-- f_DAC = f_CLK / (P * (2^N-1))
-------------------------------------------------------------------------------
-- Total # of FFs: 2*N + ceil(log2(P)) + 2
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pwm_dac is
  generic(
    N : integer := 5;   -- DAC resolution (# of bits)
    R : integer := 0;   -- reset value for DAC input (represented with N bits)
    P : integer := 1000 -- clock prescaler value
    );
  port(
    rst_pi      : in  std_logic;                    
    clk_pi      : in  std_logic;
    incr_evt_pi : in  std_logic;
    decr_evt_pi : in  std_logic;
    active_pi   : in  std_logic;
    pwm_po      : out std_logic                       -- PWM output signal
    );
end pwm_dac;

architecture rtl of pwm_dac is

  -- digitil input value counter signals
  signal dig_in_cnt  : unsigned(N-1 downto 0);
  -- Prescaler constants and signals
  constant c_psb     : natural := natural(ceil(log2(real(P)))); -- # of bits for pre-scale counter
  signal prescl_cnt  : unsigned(c_psb-1 downto 0);
  signal ref_cnt_enb : std_logic;
  -- PWM DAC signals
  signal dig_in_reg  : unsigned(N-1 downto 0);
  signal ref_cnt     : unsigned(N-1 downto 0);

begin

  -----------------------------------------------------------------------------
  -- sequential process: maintain digital input value to PWM_DAC
  -- # of FFs: N
  -----------------------------------------------------------------------------
  P_dig_in: process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then 
      dig_in_cnt <= to_unsigned(R,N);
    elsif rising_edge(clk_pi) then
    
       -- ToDo --------------
    
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- sequential process: clock prescaling generating reference counter tick
  -- # of FFs: ceil(log2(P)) + 1
  -----------------------------------------------------------------------------
  p_prescale : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      prescl_cnt  <= (others => '0');
      ref_cnt_enb <= '0';
    elsif rising_edge(clk_pi) then
      prescl_cnt  <= prescl_cnt + 1;
      ref_cnt_enb <= '0';
      if prescl_cnt = P-1 then
        prescl_cnt  <= (others => '0');
        ref_cnt_enb <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: reference counter and comparator
  -- # of FFs: N + N + 1 = 2*N + 1
  -----------------------------------------------------------------------------
  p_pwm_dac : process(rst_pi, clk_pi)
  begin
    if rst_pi = '1' then
      dig_in_reg <= to_unsigned(R,N);
      ref_cnt    <= (others => '0');
      pwm_po     <= '0';
    elsif rising_edge(clk_pi) then
      if ref_cnt_enb = '1' then


         -- ToDo -------------------------------


      end if;
    end if;
  end process;

end rtl;
