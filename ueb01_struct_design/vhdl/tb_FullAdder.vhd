library ieee;
use ieee.std_logic_1164.all;

entity tb_FullAdder is
end tb_FullAdder;

architecture TB of tb_FullAdder is

  -- signal declaration
  signal a, b, c_in, sum, c_out :std_logic;

begin
  
  -- instantiate the module under test
  -- Note: If library is known, in which component has been compiled into,
  -- instantiation is possible as shown below without component declaration.  
  MUT: entity work.FullAdder
    port map(
      a_pi => a,
      b_pi => b,
      c_pi => c_in,
      s_po => sum,
      c_po => c_out
      );

  ---------------------------------------------------------------------------
  -- stimuli application and automatic check of expected responses
  ---------------------------------------------------------------------------
  process
    -- test procedure (to be called for all combinations of input patterns)
    procedure check_stim (in1, in2, in3 : in std_logic) is
      variable act_sum,  exp_sum  : std_logic := '0';
      variable act_cout, exp_cout : std_logic := '0';
      variable check_fail         : boolean := true;
    begin
      -- 1st test pattern
      a <= in1; b <= in2; c_in <= in3;
      wait for 1ms;
      -- gather actual responses
      act_sum  := sum;
      act_cout := c_out;
      -- compute expected responses (golden model!)
      exp_sum  := (not a and not b and     c_in) or (not a and     b and not c_in) or
                  (    a and not b and not c_in) or (    a and     b and     c_in);
      exp_cout := (not a and     b and     c_in) or (    a and not b and     c_in) or
                  (    a and     b and not c_in) or (    a and     b and     c_in);
      -- compare actual and expected responses
      check_fail := (act_sum /= exp_sum) or (act_cout /= exp_cout);
      -- report result of check
      if check_fail then
        report ">> ERROR for input pattern: " & std_logic'image(in1) & " " & std_logic'image(in2)& " " & std_logic'image(in3)
          severity error;
      else
        report ">> Input pattern: " & std_logic'image(in1) & " " & std_logic'image(in2) & " " & std_logic'image(in3)  & " tested OK."
          severity note;
      end if;
    end procedure;
    
  begin
    -- apply all test patterns
    check_stim('0','0','0');
    check_stim('0','0','1');
    check_stim('0','1','0');
    check_stim('0','1','1');
    check_stim('1','0','0');
    check_stim('1','0','1');
    check_stim('1','1','0');
    check_stim('1','1','1');
 
    report ">> ==== End of Simulation ====" severity note;
    wait;
  end process;
	
end TB;
