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
    -- Init -------------------------------------------------------------------
    -- set GPIO_0(7:0) = BTN(3:0) & SW(3:0) to Input (= HW default setting for all GPIO)
    OPC(setil) & reg(0) & n2slv(16#02#, DW/2),         -- setil r0, 0x02
    OPC(setih) & reg(0) & n2slv(16#03#, DW/2),         -- setih r0, 0x03
    OPC(setil) & reg(1) & n2slv(16#00#, DW/2),         -- setil r1, 0x00
    OPC(st)    & reg(1) & reg(0) & "-----",            -- GPIO_0_OUT_ENB = 0x00
    -- set GPIO_1(7:5 & 3:0) = LED(B:G:R) & LED(3:0) to Output
    OPC(setil) & reg(0) & n2slv(16#05#, DW/2),         -- setil r0, 0x05
    OPC(setih) & reg(0) & n2slv(16#03#, DW/2),         -- setih r0, 0x03
    OPC(setil) & reg(1) & n2slv(16#EF#, DW/2),         -- setil r1, 0xEF
    OPC(st)    & reg(1) & reg(0) & "-----",            -- GPIO_1_OUT_ENB = 0xEF
    -- prepare registers being used in main loop
    OPC(setil) & reg(0) & n2slv(16#00#, DW/2),         -- setil r0, 0x00
    OPC(setih) & reg(0) & n2slv(16#03#, DW/2),         -- setih r0, 0x03 = GPIO_0_DATA_IN
    OPC(setil) & reg(1) & n2slv(16#04#, DW/2),         -- setil r1, 0x04
    OPC(setih) & reg(1) & n2slv(16#03#, DW/2),         -- setih r1, 0x03 = GPIO_1_DATA_OUT
    OPC(setil) & reg(2) & n2slv(16#E0#, DW/2),         -- setil r2, 0xEO = Mask LED_R/G/B
    OPC(setil) & reg(3) & n2slv(16#0E#, DW/2),         -- setil r3, 0x0E = Mask LED_3/2/1
    OPC(setil) & reg(4) & n2slv(16#01#, DW/2),         -- setil r4, 0x01 = Mask LED_0
    -- Main Loop --------------------------------------------------------------
    OPC(ld)    & reg(5) & reg(0) & "-----",            -- r5 := GPIO_0_DATA_IN
    
    --
    --  ........... ToDo .............
    --
    
    OPC(st)    & reg(7) & reg(1) & "-----",            -- GPIO_1_DATA_OUT := r7
    -- End Main Loop ----------------------------------------------------------
    OPC(jmp)   & "-"    & n2slv(16#0F#, AW),           -- jmp 0x00F (start of main loop)
    ---------------------------------------------------------------------------
    others => iw_nop                                   -- NOP
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

