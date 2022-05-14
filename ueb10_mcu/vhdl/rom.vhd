-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : rom
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: 
-- Program memory for simple von-Neumann MCU with registerd read data output.
-------------------------------------------------------------------------------
-- Total # of FFs: DW
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity rom is
  port(clk     : in    std_logic;
       -- ROM bus signals
       bus_in  : in  t_bus2rom;
       bus_out : out t_rom2bus
       );
end rom;

architecture rtl of rom is

  type t_rom is array (0 to 2**AWROM-1) of std_logic_vector(DW-1 downto 0);
  constant rom_table : t_rom := (
    ---------------------------------------------------------------------------
    -- program code -----------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Opcode    Rdest/D  Rsrc1/A  Rsrc2             description
    ---------------------------------------------------------------------------
    OPC(st)    & reg(0) & reg(0) & "-----",          -- store to RAM
    OPC(st)    & reg(2) & reg(1) & "-----",          -- store to RAM
    OPC(ld)    & reg(3) & reg(0) & "-----",          -- load from RAM
    OPC(ld)    & reg(4) & reg(1) & "-----",          -- load from RAM
    ---------------------------------------------------------------------------
    others => iw_nop                                 -- NOP
         );
           
begin

  -----------------------------------------------------------------------------
  -- sequential process: ROM table with registered output
  -----------------------------------------------------------------------------  
  P_rom: process(clk)
  begin
    if rising_edge(clk) then
      bus_out.data <= rom_table(to_integer(unsigned(bus_in.addr)));
    end if;
  end process;
  
end rtl;

