-------------------------------------------------------------------------------
-- Entity: tb_led_shift_mirror
-- Author: Waj
-------------------------------------------------------------------------------
-- Description:
-- Testbench for led_shift_mirror
-- NOTE:
-- The testbench assumes the following:
--  1) The blank time used for debouncing is between 15 and 22 ms.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all ; 

entity tb_led_shift_mirror is
end tb_led_shift_mirror;

architecture TB of tb_led_shift_mirror is

  -- CLK freuency scaling for simulation
  constant c_time_scl : integer := 1000;
  constant CLK_FRQ    : integer := 125_000_000/c_time_scl; -- 125 kHz
  -- simulation constants
  constant cc_time     : time := 1 sec / CLK_FRQ; -- clock cycle time
  constant click_time  : time := 22 ms;           -- time of one phase of rotary switch 
  constant bounce_time : time := 3 ms;            -- button switch bouncing time
  
  -- expected LED patterns
  constant c_led_1  : std_logic_vector(7 downto 0) := "00111100";
  constant c_led_2  : std_logic_vector(7 downto 0) := "00011110";
  constant c_led_3  : std_logic_vector(7 downto 0) := "00001111";
  constant c_led_4  : std_logic_vector(7 downto 0) := "11110000";
  constant c_led_5  : std_logic_vector(7 downto 0) := "11100000";
  constant c_led_6  : std_logic_vector(7 downto 0) := "11000000";
  constant c_led_7  : std_logic_vector(7 downto 0) := "10000000";
  constant c_led_8  : std_logic_vector(7 downto 0) := "10000000";
  constant c_led_9  : std_logic_vector(7 downto 0) := "00000001";
  constant c_led_10 : std_logic_vector(7 downto 0) := "00000001";
  constant c_led_11 : std_logic_vector(7 downto 0) := "00000011";
  constant c_led_12 : std_logic_vector(7 downto 0) := "00000111";
  constant c_led_13 : std_logic_vector(7 downto 0) := "11100000";

  -- error messages
  constant c_err  : string := ("====> Test ");

  -- DUT signals
  signal rst  : std_logic := '1';
  signal clk  : std_logic := '0';
  signal enca : std_logic := '0';
  signal encb : std_logic := '0';
  signal mirr : std_logic := '1';
  signal led  : std_logic_vector(7 downto 0);

  -- simulation control signals
  signal click_l, click_r, click_done : boolean := false;
  signal mirror, mirror_done          : boolean := false;
  signal sim_done                     : boolean := false;
  signal err_cnt                      : natural := 0;
  
begin

  -- instantiate DUT
  mut: entity work.led_shift_mirror 
    generic map(
      CLK_FRQ => CLK_FRQ
      )
    port map(
      rst_pi  => rst,
      clk_pi  => clk,
      enca_pi => enca,
      encb_pi => encb,
      mirr_pi => mirr,
      led_po => led
      );

  -- generate reset
  rst <= '0', '1' after 1.7*cc_time, '0' after 3.8*cc_time;

  -- clock generation
  p_clk: process
  begin
    if not sim_done then
      wait for cc_time/2;
      clk <= not clk;
    else
      wait;
    end if;
  end process;

  -- stop simulation after fixed time
  p_stop: process
  begin
    wait until sim_done;
    -- end of simulation
    write(std.textio.OUTPUT, ("######## End of Simulation #######" & LF));
  end process;

  -- encoder input generation
  p_enc: process
  begin
    wait until click_l or click_r;
    -- generate sequence of 4 pahses on enca/b
    wait for click_time;
    if click_l then
      enca <= '0'; encb <= '1'; 
      wait for click_time;
      enca <= '1'; encb <= '1'; 
      wait for click_time;
      enca <= '1'; encb <= '0'; 
    elsif click_r then
      enca <= '1'; encb <= '0'; 
      wait for click_time;
      enca <= '1'; encb <= '1'; 
      wait for click_time;
      enca <= '0'; encb <= '1'; 
    end if;
    wait for click_time;
    enca <= '0'; encb <= '0'; 
    -- indicate sequence done
    click_done <= true;
    wait for cc_time;
    click_done <= false;    
  end process;

  -- switch button input generation
  p_swb: process
  begin
    wait until mirror;
    -- generate button-press sequence with bouncing
    mirr <= '0';
    wait for bounce_time;
    mirr <= '1';
    wait for bounce_time/2;
    mirr <= '0';
    wait for bounce_time/4;
    mirr <= '1';
    wait for 3*bounce_time;
    mirr <= '0';
    wait for bounce_time/2;
    mirr <= '1';
    -- indicate sequence done
    mirror_done <= true;
    wait for cc_time;
    mirror_done <= false;    
  end process;

  -- check pattern displayed on LED
  p_check_led: process
    -- test procedure led pattern
    procedure check_led (exp  : in std_logic_vector(7 downto 0);
                         test : in natural) is
    begin
      if led /= exp then
        report c_err & natural'image(test) & ". exp : " & integer'image(to_integer(unsigned(exp))) & ", act : " & integer'image(to_integer(unsigned(led))) severity error;
        err_cnt <= err_cnt + 1;
      end if;
    end procedure;
  begin
    -- Test 1: default pattern on LED after reset is released
    wait until rst = '0';
    wait for 4*cc_time;
    check_led(c_led_1, 1);
    -- Test 2: click right
    click_r <= true; wait until click_done; click_r <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_2, 2);
    -- Test 3: click right
    click_r <= true; wait until click_done; click_r <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_3, 3);
    -- Test 4: mirrow
    mirror <= true; wait until mirror_done; mirror <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_4, 4);
    -- Test 5: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_5, 5);
    -- Test 6: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_6, 6);
    -- Test 7: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_7, 7);
    -- Test 8: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_8, 8);
    -- Test 9: mirrow
    mirror <= true; wait until mirror_done; mirror <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_9, 9);
    -- Test 10: click right
    click_r <= true; wait until click_done; click_r <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_10, 10);
    -- Test 11: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_11, 11);
    -- Test 12: click left
    click_l <= true; wait until click_done; click_l <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_12, 12);
    -- Test 13: mirrow
    mirror <= true; wait until mirror_done; mirror <= false;
    wait for 1.5*bounce_time;
    check_led(c_led_13, 13);
    -- print test statistics and end simulation -----------------------------------------
    wait for 4*cc_time;
    write(std.textio.OUTPUT, (LF & "# of Tests failed = " & integer'image(err_cnt) & LF));
    sim_done <= true;
    wait;
  end process;  

end TB;
