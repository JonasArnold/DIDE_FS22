-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : mcu_pkg
-- Author : Waj
-------------------------------------------------------------------------------
-- Description: 
-- Top-level description of a simple von-Neumann MCU.
-- All top-level component are instantiated here. Also, tri-state buffers for
-- bi-directional GPIO pins are described here.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity mcu is
  port(rst     : in    std_logic;
       clk     : in    std_logic;
       -- General-Purpose I/O ports
       gpio_0     : inout std_logic_vector(c_gpio_port_ww-1 downto 0);
       gpio_1     : inout std_logic_vector(c_gpio_port_ww-1 downto 0);
       -- FMC ports (3 pins per FMC channel)
       fmc_enable : out std_logic_vector(c_fmc_num_chn-1 downto 0);
       fmc_direct : out std_logic_vector(c_fmc_num_chn-1 downto 0);
       fmc_step   : out std_logic_vector(c_fmc_num_chn-1 downto 0)
       );
end mcu;

architecture rtl of mcu is

  -- CPU signals
  signal cpu2bus : t_cpu2bus;
  signal bus2cpu : t_bus2cpu;
  -- ROM signals
  signal bus2rom : t_bus2rom;
  signal rom2bus : t_rom2bus;
  -- RAM signals
  signal bus2ram : t_bus2ram;
  signal ram2bus : t_ram2bus;
  -- GPIO signals
  signal bus2gpio   : t_bus2rws;
  signal gpio2bus   : t_rws2bus;
  signal gpio_0_in  : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_0_out : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_0_enb : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_1_in  : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_1_out : std_logic_vector(c_gpio_port_ww-1 downto 0);
  signal gpio_1_enb : std_logic_vector(c_gpio_port_ww-1 downto 0);
  -- FMC signals
  signal bus2fmc    : t_bus2rws;
  signal fmc2bus    : t_rws2bus;
  -- Local reset synchronization
  signal rst_sr     : std_logic_vector(3 downto 0);
  signal rst_local  : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Synchronize de-activating edge of local reset to clock signal
  -----------------------------------------------------------------------------  
  sync_rst_rel: process(clk, rst)
  begin
    if rst = '1' then
      rst_sr    <= (others => '1');
      rst_local <= '1';
   elsif rising_edge(clk) then
      rst_sr(0)          <= '0';
      rst_sr(3 downto 1) <= rst_sr(2 downto 0);
      rst_local          <= rst_sr(3);          
   end if;
  end process;

  -----------------------------------------------------------------------------
  -- Tri-state buffers for GPIO pins
  -----------------------------------------------------------------------------
  gpio_0_in <= gpio_0;
  gpio_1_in <= gpio_1;
  gen_3st_pin: for k in 0 to c_gpio_port_ww-1 generate
    gpio_0(k) <= gpio_0_out(k) when gpio_0_enb(k) = '1' else 'Z';
    gpio_1(k) <= gpio_1_out(k) when gpio_1_enb(k) = '1' else 'Z';
  end generate;

  -----------------------------------------------------------------------------
  -- Instantiation of top-level components (assumed to be in library work)
  -----------------------------------------------------------------------------
  -- CPU ----------------------------------------------------------------------
  i_cpu: entity work.cpu
    port map(
      rst     => rst_local,
      clk     => clk,
      bus_in  => bus2cpu,
      bus_out => cpu2bus
    );

  -- BUS ----------------------------------------------------------------------
  i_bus: entity work.buss
    port map(
      rst      => rst_local,
      clk      => clk,
      cpu_in   => cpu2bus,
      cpu_out  => bus2cpu,
      rom_in   => rom2bus,
      rom_out  => bus2rom,
      ram_in   => ram2bus,
      ram_out  => bus2ram,
      gpio_in  => gpio2bus,
      gpio_out => bus2gpio,
      fmc_in   => fmc2bus,
      fmc_out  => bus2fmc
    );

  -- ROM ----------------------------------------------------------------------
  i_rom: entity work.rom
    port map(
      clk     => clk,
      bus_in  => bus2rom,
      bus_out => rom2bus
    );

  -- RAM ----------------------------------------------------------------------
  i_ram: entity work.ram
    port map(
      clk     => clk,
      bus_in  => bus2ram,
      bus_out => ram2bus
    );
  
  -- GPIO ---------------------------------------------------------------------
  i_gpio: entity work.gpio
    port map(
      rst        => rst_local,
      clk        => clk,
      bus_in     => bus2gpio,
      bus_out    => gpio2bus,
      gpio_0_in  => gpio_0_in,
      gpio_0_out => gpio_0_out,
      gpio_0_enb => gpio_0_enb,
      gpio_1_in  => gpio_1_in,
      gpio_1_out => gpio_1_out,
      gpio_1_enb => gpio_1_enb
    );

  -- FMC ----------------------------------------------------------------------
  i_fmc: entity work.fmc_top
    generic map(CF => CF)
    port map(
      rst        => rst_local,
      clk        => clk,
      bus_in     => bus2fmc,
      bus_out    => fmc2bus,
      fmc_enable => fmc_enable,
      fmc_direct => fmc_direct,
      fmc_step   => fmc_step
    );

end rtl;
