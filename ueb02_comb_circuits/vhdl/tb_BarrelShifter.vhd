library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarrelShifter_TB is
end BarrelShifter_TB;

architecture TB of BarrelShifter_TB is

  component BarrelShifter is
    port(
      dataIn  : in  std_logic_vector(7 downto 0);
      shift   : in  std_logic_vector(3 downto 0);
      dataOut : out std_logic_vector(7 downto 0)
      );
  end component BarrelShifter;

  signal dataIn  : std_logic_vector(7 downto 0) := "11110110";
  signal shift   : std_logic_vector(3 downto 0);
  signal dataOut : std_logic_vector(7 downto 0);
  
begin

  MUT : BarrelShifter
    port map(
      dataIn  => dataIn,
      shift   => shift,
      dataOut => dataOut
      );

  process
    variable v_exp : integer;
  begin
    -- apply all different shift stimuli
    -- NOTE: Only symmetrical 2sC range supported by MUT!!!
    for s in -(2**(shift'length-1)-1) to 2**(shift'length-1)-1 loop
      shift <= std_logic_vector(to_signed(s, shift'length));
      -- construct expected response for current stimuli
      -- NOTE 1: Intermediate conversion to type real is necessary, because
      -- negative exponent is not supported for type integer.
      -- NOTE 2: -0.5 is necessary because right shift corresponds to 
      -- truncation while type casting to integer corresponds to rounding.
      -- NOTE 3: mod 2^8 is necessary because left shift corresponds to
      -- multiplication modulo supported number range.
      v_exp := integer(real(to_integer(unsigned(dataIn)))*(2.0**s)-0.5)
               mod 2**dataOut'length;
      -- wait some time before checking actual response 
      wait for 1ms;
      -- compare actual and expected response
      assert v_exp = to_integer(unsigned(dataOut))
        report "ERROR for shift = " & integer'image(s) severity note;
    end loop;
    -- End of simulation    
    report "End of simulation." severity note;
    wait; -- suspend process forever
  end process;
  
end TB;

