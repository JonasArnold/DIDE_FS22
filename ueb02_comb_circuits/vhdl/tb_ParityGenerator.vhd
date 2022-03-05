library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ParityGenerator is
end tb_ParityGenerator;

architecture TB of tb_ParityGenerator is
  component ParityGenerator is
    port(
      data   : in  std_logic_vector(3 downto 0);
      parity : out std_logic
      );
  end component ParityGenerator;

  -- configure architecture of UUT to be simulated
  for MUT : ParityGenerator use entity work.ParityGenerator(xor_chain);

  signal data   : std_logic_vector(3 downto 0);
  signal parity : std_logic;

begin
  
  MUT : ParityGenerator
    port map(
      data   => data,
      parity => parity
      ); 

  process
  begin
    for i in 0 to 2**data'length - 1 loop
      -- apply stimuli
      data <= std_logic_vector(to_unsigned(i, data'length));
      -- wait some time before applying next stimuli
      wait for 1ms;
    end loop;
    -- No automatic response checking!!!! Must compare waveforms!
    report "End of simulation." severity note;
    wait;
  end process;
  
end TB;
