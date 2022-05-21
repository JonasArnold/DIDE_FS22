-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : ram
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Data/address/control bus for simple von-Neumann MCU.
-- The bus master (CPU) can read/write in every cycle. The bus slaves are
-- assumed to have registerd read data output with an address-in to data-out
-- latency of 1 cc. The read data muxing from bus slaves to the bus master is
-- done combinationally. Thus, at the bus master interface, there results a
-- read data latency of 1 cc.
-------------------------------------------------------------------------------
-- Total # of FFs: 2
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity buss is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- CPU bus signals
       cpu_in  : in  t_cpu2bus;
       cpu_out : out t_bus2cpu;
       -- ROM bus signals
       rom_in  : in  t_rom2bus;
       rom_out : out t_bus2rom;
       -- RAM bus signals
       ram_in  : in  t_ram2bus;
       ram_out : out t_bus2ram;
       -- GPIO bus signals
       gpio_in  : in  t_rws2bus;
       gpio_out : out t_bus2rws;
       -- FMC bus signals
       fmc_in  : in  t_rws2bus;
       fmc_out : out t_bus2rws
       );
end buss;

architecture rtl of buss is 

  -- currently addressed bus slave
  signal bus_slave : t_bus_slave;
  
begin

  -----------------------------------------------------------------------------
  -- address decoding
  -----------------------------------------------------------------------------
  -- convey lower address bist from CPU to all bus slaves
  rom_out.addr  <= cpu_in.addr(AWROM-1 downto 0);
  ram_out.addr  <= cpu_in.addr(AWRAM-1 downto 0);
  gpio_out.addr <= cpu_in.addr(AWPER-1 downto 0);
  fmc_out.addr  <= cpu_in.addr(AWPER-1 downto 0);
  -- combinational process:
  -- determine addressed slave by decoding higher address bits
  -----------------------------------------------------------------------------
  P_dec: process(cpu_in)
   variable v_addr_match : boolean; 
  begin  
    bus_slave <= t_bus_slave'left; -- default assignment
    for s in t_bus_slave loop
      -- over all slaves
      if std_match(cpu_in.addr(AW-1 downto AW-AWH), HBA(s)) then
        bus_slave <= s;
      end if;
    end loop;
  end process;

  -----------------------------------------------------------------------------
  -- write transfer logic
  -----------------------------------------------------------------------------
  -- convey write data from CPU to all bus slaves 
  -- rom is read-only slave
  ram_out.data  <= cpu_in.data;
  gpio_out.data <= cpu_in.data;
  fmc_out.data  <= cpu_in.data;
  -- convey write enable from CPU to addressed slave only
  ram_out.wr_enb  <= cpu_in.wr_enb when bus_slave = RAM else '0';
  gpio_out.wr_enb <= cpu_in.wr_enb when bus_slave = GPIO else '0';
  fmc_out.wr_enb  <= cpu_in.wr_enb when bus_slave = FMC else '0';
 
  -----------------------------------------------------------------------------
  -- read transfer logic
  -----------------------------------------------------------------------------
  -- read data mux
--ToDo!!!  with ............. select cpu_out.data <= rom_in.data      when ROM,
--                                                   ram_in.data      when RAM,
--                                                   gpio_in.data     when GPIO,
--                                                   fmc_in.data      when FMC,
--                                                   (others => '-')  when others;
  -- convey read enable from CPU to addressed slave only
  gpio_out.rd_enb <= cpu_in.rd_enb when bus_slave = GPIO else '0';
  fmc_out.rd_enb  <= cpu_in.rd_enb when bus_slave = FMC  else '0';
  -- sequential process:
  -- register decode information to compensate read-latency of slaves
  -----------------------------------------------------------------------------  
  P_reg: process(rst, clk)
  begin
    if rst = '1' then
       -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    elsif rising_edge(clk) then
       -- ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end if;
  end process;
  
end rtl;
