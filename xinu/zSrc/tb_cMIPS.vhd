-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--  cMIPS, a VHDL model of the classical five stage MIPS pipeline.
--  Copyright (C) 2013  Roberto Andre Hexsel
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, version 3.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- testbench for classicalMIPS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity tb_cMIPS is
end tb_cMIPS;

architecture TB of tb_cMIPS is

  component FFD is
    port(clk, rst, set, D : in std_logic; Q : out std_logic);
  end component FFD;

  component LCD_display is
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          addr     : in    std_logic; -- 0=constrol, 1=data
          data_inp : in    std_logic_vector(31 downto 0);
          data_out : out   std_logic_vector(31 downto 0);
          LCD_DATA : inout std_logic_vector(7 downto 0);  -- bidirectional bus
          LCD_RS   : out   std_logic; -- LCD register select 0=ctrl, 1=data
          LCD_RW   : out   std_logic; -- LCD read=1, 0=write
          LCD_EN   : out   std_logic; -- LCD enable=1
          LCD_BLON : out   std_logic);
  end component LCD_display;

  component to_7seg is
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          wr       : in  std_logic;
          data     : in  std_logic_vector;
          display0 : out std_logic_vector;
          display1 : out std_logic_vector);
  end component to_7seg;

  component read_keys is
    generic (DEB_CYCLES : natural);
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          data     : out reg32;
          kbd      : in  std_logic_vector (11 downto 0);
          sw       : in  std_logic_vector (3 downto 0));
  end component read_keys;

  component to_stdout is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          wr      : in  std_logic;
          data    : in  std_logic_vector);
  end component to_stdout;

  component from_stdin is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          wr      : in  std_logic;
          data    : out std_logic_vector);
  end component from_stdin;

  component print_data is
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          wr      : in  std_logic;
          data    : in  std_logic_vector);
  end component print_data;
  
  component write_data_file is
    generic (OUTPUT_FILE_NAME : string);
    port (rst      : in  std_logic;
          clk      : in  std_logic;
          sel      : in  std_logic;
          wr       : in  std_logic;
          addr     : in  std_logic_vector;
          data     : in  std_logic_vector;
          byte_sel : in  std_logic_vector;
          dump_ram : out std_logic);
  end component write_data_file;

  component read_data_file is
    generic (INPUT_FILE_NAME : string);
    port (rst     : in  std_logic;
          clk     : in  std_logic;
          sel     : in  std_logic;
          wr      : in  std_logic;
          addr    : in  std_logic_vector;
          data    : out std_logic_vector;
          byte_sel: in  std_logic_vector);
  end component read_data_file;

  component do_interrupt is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          wr      : in    std_logic;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          irq      : out  std_logic);
  end component do_interrupt;

  component simple_uart is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector;
          txdat   : out   std_logic;
          rxdat   : in    std_logic;
          rts     : out   std_logic;
          cts     : in    std_logic;
          irq     : out   std_logic;
          bit_rt  : out   std_logic_vector);-- communication speed - TB only
  end component simple_uart;

  component FPU is
    port (rst      : in   std_logic;
          clk      : in   std_logic;
          sel      : in   std_logic;
          rdy      : out  std_logic;
          wr       : in   std_logic;
          addr     : in   std_logic_vector;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector);
  end component FPU;

  component fake_FPU is
    port (rst      : in   std_logic;
          clk      : in   std_logic;
          sel      : in   std_logic;
          rdy      : out  std_logic;
          wr       : in   std_logic;
          addr     : in   std_logic_vector;
          data_inp : in   std_logic_vector;
          data_out : out  std_logic_vector);
  end component fake_FPU;

  component remota is
    generic(OUTPUT_FILE_NAME : string; INPUT_FILE_NAME : string);
    port(rst, clk  : in  std_logic;
         start     : in  std_logic;
         inpDat    : in  std_logic;    -- serial input
         outDat    : out std_logic;    -- serial output
         bit_rt    : in  std_logic_vector);
  end component remota;

  component sys_stats is
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          wr      : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector;
          cnt_dc_ref    : in  integer;
          cnt_dc_rd_hit : in  integer;
          cnt_dc_wr_hit : in  integer;
          cnt_dc_flush  : in  integer;
          cnt_ic_ref : in  integer;
          cnt_ic_hit : in  integer);
  end component sys_stats;

  
  component ram_addr_decode is
    port (rst         : in  std_logic;
          cpu_d_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic;
          dev_select  : out std_logic_vector);
  end component ram_addr_decode;

  component io_addr_decode is
    port (clk         : in  std_logic;
          rst         : in  std_logic;
          cpu_d_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          dev_select  : out std_logic_vector;
          print_sel   : out std_logic;
          stdout_sel  : out std_logic;
          stdin_sel   : out std_logic;
          read_sel    : out std_logic;
          write_sel   : out std_logic;
          counter_sel : out std_logic;
          FPU_sel     : out std_logic;
          uart_sel    : out std_logic;
          sstats_sel  : out std_logic;
          dsp7seg_sel : out std_logic;
          keybd_sel   : out std_logic;
          lcd_sel     : out std_logic;
          not_waiting : in  std_logic);
  end component io_addr_decode;

  component busError_addr_decode is
    port (rst         : in  std_logic;
          cpu_d_aVal  : in  std_logic;
          addr        : in  reg32;
          d_busError  : out std_logic); -- decoded address not in range (act=0)
  end component busError_addr_decode;
  
  component inst_addr_decode is
    port (rst         : in  std_logic;
          cpu_i_aVal  : in  std_logic;
          addr        : in  std_logic_vector;
          aVal        : out std_logic;
          i_busError  : out std_logic);
  end component inst_addr_decode;
    
  component simul_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          strobe  : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component simul_ROM;

  component fpga_ROM is 
    generic (LOAD_FILE_NAME : string);
    port (rst     : in    std_logic;
          clk     : in    std_logic;
          sel     : in    std_logic;
          rdy     : out   std_logic;
          strobe  : in    std_logic;
          addr    : in    std_logic_vector;
          data    : out   std_logic_vector);
  end component fpga_ROM;

  component simul_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          strobe   : in    std_logic;
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component simul_RAM;

  component fpga_RAM is
    generic (LOAD_FILE_NAME : string; DUMP_FILE_NAME : string);
    port (rst      : in    std_logic;
          clk      : in    std_logic;
          sel      : in    std_logic;
          rdy      : out   std_logic;
          wr       : in    std_logic;
          strobe   : in    std_logic;
          addr     : in    std_logic_vector;
          data_inp : in    std_logic_vector;
          data_out : out   std_logic_vector;
          byte_sel : in    std_logic_vector;
          dump_ram : in    std_logic);
  end component fpga_RAM;

  component fake_I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component fake_I_CACHE;

  component I_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE;

  component I_CACHE_fpga is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          ic_reset : out   std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data : out   std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_addr : out   std_logic_vector;
          mem_data : in    std_logic_vector;
          ref_cnt  : out   integer;
          hit_cnt  : out   integer);
  end component I_CACHE_fpga;

  component fake_D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component fake_D_CACHE;

  component D_CACHE is
    port (rst      : in    std_logic;
          clk4x    : in    std_logic;
          cpu_sel  : in    std_logic;
          cpu_rdy  : out   std_logic;
          cpu_wr   : in    std_logic;
          cpu_addr : in    std_logic_vector;
          cpu_data_inp : in  std_logic_vector;
          cpu_data_out : out std_logic_vector;
          cpu_xfer : in    std_logic_vector;
          mem_sel  : out   std_logic;
          mem_rdy  : in    std_logic;
          mem_wr   : out   std_logic;
          mem_addr : out   std_logic_vector;
          mem_data_inp : in  std_logic_vector;
          mem_data_out : out std_logic_vector;
          mem_xfer : out   std_logic_vector;
          ref_cnt  : out   integer;
          rd_hit_cnt : out integer;
          wr_hit_cnt : out integer;
          flush_cnt  : out integer);
  end component D_CACHE;
  
  component core is
    port (rst    : in    std_logic;
          clk    : in    std_logic;
          phi1   : in    std_logic;
          phi2   : in    std_logic;
          phi3   : in    std_logic;
          i_aVal : out   std_logic;
          i_wait : in    std_logic;
          i_addr : out   std_logic_vector;
          instr  : in    std_logic_vector;
          d_aVal : out   std_logic;
          d_wait : in    std_logic;
          d_addr : out   std_logic_vector;
          data_inp : in  std_logic_vector;
          data_out : out std_logic_vector;
          wr     : out   std_logic;
          b_sel  : out   std_logic_vector;
          nmi    : in    std_logic;
          irq    : in    std_logic_vector;
          i_busErr : in  std_logic;
          d_busErr : in  std_logic);
  end component core;

  component mf_altpll port (
    areset          : IN  STD_LOGIC;
    inclk0          : IN  STD_LOGIC;
    c0              : OUT STD_LOGIC;
    c1              : OUT STD_LOGIC;
    c2              : OUT STD_LOGIC;
    c3              : OUT STD_LOGIC;
    c4              : OUT STD_LOGIC);
  end component mf_altpll;

  component mf_altpll_io port (
    areset          : IN  STD_LOGIC;
    inclk0          : IN  STD_LOGIC;
    c0              : OUT STD_LOGIC;
    c1              : OUT STD_LOGIC;
    c2              : OUT STD_LOGIC);
  end component mf_altpll_io;
  
  component mf_altclkctrl port (
    inclk  : IN  STD_LOGIC;
    outclk : OUT STD_LOGIC); 
  end component mf_altclkctrl;
  
  signal clock_50mhz, clk,clkin : std_logic;
  signal clk4x,clk4x0, clk4x180, clk2x : std_logic;
  signal phi0,phi1,phi2,phi3,phi0in,phi1in,phi2in,phi3in, phi2_dlyd : std_logic;
  signal rst,ic_reset,a_rst1,a_rst2,a_rst3, cpu_reset : std_logic;
  signal a_reset, async_reset : std_logic;
  signal cpu_i_aVal, cpu_i_wait, wr, cpu_d_aVal, cpu_d_wait : std_logic;
  signal nmi, i_busError, d_busError : std_logic;
  signal irq : reg6;
  signal inst_aVal, inst_wait, rom_rdy : std_logic := '1';
  signal data_aVal, data_wait, ram_rdy, mem_wr : std_logic;
  signal cpu_xfer, mem_xfer, dev_select, dev_select_ram, dev_select_io : reg4;
  signal io_print_sel   : std_logic := '1';
  signal io_stdout_sel  : std_logic := '1';
  signal io_stdin_sel   : std_logic := '1';
  signal io_write_sel   : std_logic := '1';
  signal io_read_sel    : std_logic := '1';
  signal io_counter_sel : std_logic := '1';
  signal io_uart_sel    : std_logic := '1';
  signal io_sstats_sel  : std_logic := '1';
  signal io_7seg_sel    : std_logic := '1';
  signal io_keys_sel    : std_logic := '1';
  signal io_fpu_sel,     io_fpu_wait     : std_logic := '1';
  signal io_lcd_sel,     io_lcd_wait     : std_logic := '1';
  signal d_cache_d_out, stdin_d_out, read_d_out, counter_d_out : reg32;
  signal fpu_d_out, uart_d_out, sstats_d_out, keybd_d_out : reg32;
  signal lcd_d_out : reg32;

  signal counter_irq : std_logic;
  signal io_wait, not_waiting : std_logic;
  signal i_addr,d_addr,p_addr : reg32;
  signal datrom, datram_inp,datram_out, cpu_instr : reg32;
  signal cpu_data_inp, cpu_data_out, cpu_data : reg32;
  signal mem_i_sel, mem_d_sel: std_logic;
  signal mem_i_addr, mem_addr, mem_d_addr: reg32;
  signal cnt_i_ref,cnt_i_hit : integer;
  signal cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush : integer;

  signal dump_ram : std_logic;
  
  signal start_remota : std_logic;
  signal bit_rt : reg3;

  -- Macnica development board's peripherals
  signal disp0,disp1 : reg8;            -- 7 segment displays
  signal keys : reg12;                  -- 12key telephone keyboard
  signal switches : reg4;               -- 4 switches
  signal led_r, led_g, led_b : std_logic;  -- RGB leds
  signal LCD_DATA : std_logic_vector(7 downto 0);  -- LCD data bus
  signal LCD_RS, LCD_RW, LCD_EN, LCD_BLON : std_logic;  -- LCD control
  signal uart_txd, uart_rxd, uart_rts, uart_cts, uart_irq : std_logic;
  
begin  -- TB


  pll : mf_altpll port map (areset => a_reset, inclk0 => clock_50mhz,
   c0 => phi0in, c1 => phi1in, c2 => phi2in, c3 => phi3in, c4 => clkin);

  -- pll_io : mf_altpll_io port map (areset => a_reset, inclk0 => clock_50mhz,
  --  c0 => clk2x, c1 => clk4x0, c2 => clk4x180);
  clk2x    <= '0';
  clk4x0   <= '0';
  clk4x180 <= '0';

  mf_altclkctrl_inst_clk : mf_altclkctrl port map (
    inclk => clkin, outclk => clk);

  mf_altclkctrl_inst_clk4x : mf_altclkctrl port map (
    inclk => clk4x180, outclk => clk4x);

  mf_altclkctrl_inst_phi0 : mf_altclkctrl port map (
    inclk => phi0in, outclk => phi0);
  mf_altclkctrl_inst_phi1 : mf_altclkctrl port map (
    inclk => phi1in, outclk => phi1);
  mf_altclkctrl_inst_phi2 : mf_altclkctrl port map (
    inclk => phi2in, outclk => phi2);
  mf_altclkctrl_inst_phi3 : mf_altclkctrl port map (
    inclk => phi3in, outclk => phi3);

  -- synchronize reset
  a_rst1 <= a_reset or rst;
  U_SYNC_RESET1: FFD port map (clk, a_rst2,  '1', a_rst1,  rst);
  U_SYNC_RESET2: FFD port map (clk, a_reset, '1', '1',     a_rst2);

  async_reset <= rst and ic_reset;
  U_SYNC_RESET3: FFD port map (clk, rst, '1', async_reset, a_rst3);
  U_SYNC_RESET4: FFD port map (clk, rst, '1', a_rst3,      cpu_reset);

  
  cpu_i_wait <= inst_wait;
  cpu_d_wait <= data_wait and io_wait;
  io_wait    <= '1'; -- io_lcd_wait and io_fpu_wait;

  not_waiting <= (inst_wait and data_wait); --  and io_wait);

  -- irq <= b"000000"; -- NO interrupt requests
  irq <= uart_irq & counter_irq & b"0000"; -- uart+counter interrupts
  -- irq <= counter_irq & b"00000"; -- counter interrupts
  nmi <= '0'; -- input port to TB

  U_CORE: core port map (cpu_reset, clk, phi1,phi2,phi3,
                         cpu_i_aVal, cpu_i_wait, i_addr, cpu_instr,
                         cpu_d_aVal, cpu_d_wait, d_addr, cpu_data_inp, cpu_data,
                         wr, cpu_xfer, nmi, irq, i_busError, d_busError);

  U_INST_ADDR_DEC: inst_addr_decode
    port map (rst, cpu_i_aVal, i_addr, inst_aVal, i_busError);
  
  U_I_CACHE: fake_i_cache   -- or i_cache
  -- U_I_CACHE: i_cache  -- or fake_i_cache
  -- U_I_CACHE: i_cache_fpga  -- or FPGA implementation 
    port map (rst, clk4x, ic_reset,
              inst_aVal, inst_wait, i_addr,      cpu_instr,
              mem_i_sel,  rom_rdy,   mem_i_addr, datrom, cnt_i_ref,cnt_i_hit);

  U_ROM: simul_ROM generic map ("prog.bin")
  -- U_ROM: fpga_ROM generic map ("prog.bin")
    port map (rst, clk, mem_i_sel,rom_rdy, phi3, mem_i_addr,datrom);

  U_DATA_BUS_ERROR_DEC: busError_addr_decode
    port map (rst, cpu_d_aVal, d_addr, d_busError);

  U_IO_ADDR_DEC: io_addr_decode
    port map (phi0, rst, cpu_d_aVal, d_addr, dev_select_io,
              io_print_sel, io_stdout_sel, io_stdin_sel,io_read_sel, 
              io_write_sel, io_counter_sel, io_fpu_sel, io_uart_sel,
              io_sstats_sel, io_7seg_sel, io_keys_sel, io_lcd_sel,
              not_waiting);

  U_DATA_ADDR_DEC: ram_addr_decode
    port map (rst, cpu_d_aVal, d_addr,data_aVal, dev_select_ram);

  dev_select <= dev_select_io or dev_select_ram;
  
  with dev_select select
    cpu_data_inp <= d_cache_d_out   when b"0001",
                    stdin_d_out     when b"0100",
                    read_d_out      when b"0101",
                    counter_d_out   when b"0111",
                    fpu_d_out       when b"1000",
                    uart_d_out      when b"1001",
                    sstats_d_out    when b"1010",
                    keybd_d_out     when b"1100",
                    lcd_d_out       when b"1101",
                    (others => 'X') when others;
  
  U_D_CACHE: fake_d_cache  -- or d_cache
  -- U_D_CACHE: d_cache  -- or fake_d_cache
    port map (rst, clk4x,
              data_aVal, data_wait, wr,
              d_addr, cpu_data, d_cache_d_out, cpu_xfer,
              mem_d_sel, ram_rdy,   mem_wr,
              mem_addr,  datram_inp, datram_out,   mem_xfer,
              cnt_d_ref, cnt_d_rd_hit, cnt_d_wr_hit, cnt_d_flush);

  U_RAM: simul_RAM generic map ("data.bin", "dump.data")
  -- U_RAM: fpga_RAM generic map ("data.bin", "dump.data")
    port map (rst, clk, mem_d_sel, ram_rdy, mem_wr, phi2,
              mem_addr, datram_out, datram_inp, mem_xfer, dump_ram);


  
  U_to_stdout: to_stdout
    port map (rst,clk, io_stdout_sel, wr, cpu_data);

  U_from_stdin: from_stdin
    port map (rst,clk, io_stdin_sel,  wr, stdin_d_out);

  U_read_inp: read_data_file generic map ("input.data")
    port map (rst,clk, io_read_sel,  wr, d_addr,read_d_out, cpu_xfer);

  U_write_out: write_data_file generic map ("output.data")
    port map (rst,clk, io_write_sel, wr, d_addr,cpu_data, cpu_xfer, dump_ram);

  U_print_data: print_data
    port map (rst,clk, io_print_sel, wr, cpu_data);


  
  U_interrupt_counter: do_interrupt     -- external counter+interrupt
    port map (rst,clk, io_counter_sel, wr, cpu_data,
              counter_d_out, counter_irq);


  
  U_to_7seg: to_7seg
    port map (rst,clk,io_7seg_sel, wr, cpu_data, disp0, disp1);

  keys <= b"000000000000", b"000000000100" after 1 us, b"000000000000" after 2 us,  b"001000000000" after 3 us, b"000000000000" after 4 us, b"000001000000" after 5 us, b"000000000000" after 6 us; 
  switches <= b"0000";
          
  U_read_keys: read_keys
    generic map (6)        -- debouncing interval, in clock cycles
    port map (rst,clk, io_keys_sel, keybd_d_out, keys, switches);

  led_r <= keybd_d_out(0);
  led_g <= keybd_d_out(1);
  led_b <= keybd_d_out(2);

  U_LCD_display: LCD_display
    port map (rst, clk, io_lcd_sel, io_lcd_wait,
              wr, d_addr(2), cpu_data, lcd_d_out,
              lcd_data, lcd_rs, lcd_rw, lcd_en, lcd_blon);
  
  U_simple_uart: simple_uart
    port map (rst,clk, io_uart_sel, wr, d_addr(2), cpu_data, uart_d_out,
              uart_txd, uart_rxd, uart_rts, uart_cts, uart_irq, bit_rt);
              -- uncoment next line for loop back, comment out previous line
              -- uart_txd, uart_txd, uart_rts, uart_cts, uart_irq, bit_rt);

  uart_cts <= '1';
  
  start_remota <= '0', '1' after 200*CLOCK_PER;
  
  U_uart_remota: remota generic map ("serial.out","serial.inp")
    port map (rst, clk, start_remota, uart_txd, uart_rxd, bit_rt);

  -- U_FPU: fake_FPU
  U_FPU: FPU
    port map (rst,clk, io_FPU_sel,io_FPU_wait, wr, d_addr(5 downto 2),
              cpu_data,fpu_d_out);

  -- U_sys_stats: sys_stats                -- CPU reads system counters
  --   port map (cpu_reset,clk, io_sstats_sel, wr, d_addr, sstats_d_out,
  --             cnt_d_ref,cnt_d_rd_hit,cnt_d_wr_hit,cnt_d_flush,
  --             cnt_i_ref,cnt_i_hit);


  
  U_clock: process    -- simulate external clock
  begin
    clock_50mhz <= '1';
    wait for CLOCK_PER / 2;
    clock_50mhz <= '0';
    wait for CLOCK_PER / 2;
  end process;  -- -------------------------------------------------------
  
  -- simulate reset switch bounces
  a_reset <= '1', '0' after 5 ns, '1' after 8 ns, '0' after 12 ns,  '1' after 14 ns, '0' after 18 ns, '1' after 25 ns;

end architecture TB;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- instruction address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity inst_addr_decode is              -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_i_aVal  : in  std_logic;    -- CPU instr addr valid (act=0)
        addr        : in  reg32;        -- CPU address
        aVal        : out std_logic;    -- decoded address in range (act=0)
        i_busError  : out std_logic);   -- decoded address not in range (act=0)
end entity inst_addr_decode;

architecture behavioral of inst_addr_decode is
  constant HI_ADDR : integer := HI_SEL_BITS;
  constant LO_ADDR : integer := log2_ceil(INST_BASE_ADDR + INST_MEM_SZ);
  constant PREFIX : std_logic_vector(HI_ADDR downto LO_ADDR) := (others=>'0');

  signal in_range : boolean;
begin

  in_range <= (addr(HI_ADDR downto LO_ADDR) = PREFIX);

  aVal <= '0' when ( cpu_i_aVal = '0' and rst = '1' and in_range ) else
          '1';

  i_busError <= '0' when ( cpu_i_aVal = '0' and rst = '1'
                           and not(in_range) ) else
                '1';
  
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- RAM address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity ram_addr_decode is               -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  reg32;        -- CPU address
        aVal        : out std_logic;    -- data address (act=0)
        dev_select  : out reg4);        -- select input to CPU
  constant LO_ADDR  : integer := log2_ceil(DATA_BASE_ADDR);
  constant HI_ADDR  : integer := log2_ceil(DATA_BASE_ADDR + DATA_MEM_SZ - 1);
  constant in_r : std_logic_vector(HI_ADDR downto LO_ADDR) := (others => '1');
  constant ng_r : std_logic_vector(HI_ADDR downto LO_ADDR) := (others => '0');
  constant oth  : std_logic_vector(HI_SEL_BITS downto HI_ADDR+1):=(others=>'1');
  constant ng_o : std_logic_vector(HI_SEL_BITS downto HI_ADDR+1):=(others=>'0');
end entity ram_addr_decode;

architecture behavioral of ram_addr_decode is
--   constant LO_ADDR : natural := log2_ceil(DATA_BASE_ADDR);
--   constant HI_ADDR : natural := log2_ceil(DATA_BASE_ADDR + DATA_MEM_SZ - 1);
  
  constant all_0  : std_logic_vector(31 downto 0)         := (others=>'0');
  
  constant a_hi   : std_logic_vector(31 downto HI_ADDR+1) := (others=>'0');
  constant a_lo   : std_logic_vector(LO_ADDR-1 downto 0)  := (others=>'0');
  constant a_bits : std_logic_vector(HI_ADDR downto LO_ADDR) := (others=>'1');
  constant a_mask : std_logic_vector := a_hi & a_bits & a_lo;

  constant LO_RAM : natural := 0;
  constant HI_RAM : natural := log2_ceil(DATA_MEM_SZ-1);
  constant r_hi   : std_logic_vector(31 downto HI_RAM+1)   := (others=>'1');
  constant r_lo   : std_logic_vector(HI_RAM downto LO_RAM) := (others=>'0');
  constant r_mask : std_logic_vector := r_hi & r_lo;
    
  signal in_range : boolean;

  constant RAM_ADDR_BOTTOM : natural :=
        to_integer(signed(x_DATA_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)));
  constant RAM_ADDR_RANGE : natural :=
    (to_integer(signed(x_DATA_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS)))
     +
     to_integer(signed(x_DATA_MEM_SZ(HI_SEL_BITS downto LO_SEL_BITS))));
  constant RAM_ADDR_TOP : natural := RAM_ADDR_BOTTOM + RAM_ADDR_RANGE;

begin

--   in_range <= ( rst = '1'
--                 and ((addr and a_mask) = x_DATA_BASE_ADDR)
--                 and ((addr and r_mask) = x_DATA_BASE_ADDR) );

-- this works only for small RAMS
--   in_range <= ( addr(HI_SEL_BITS downto LO_SEL_BITS)
--                 =
--                 x_DATA_BASE_ADDR(HI_SEL_BITS downto LO_SEL_BITS) );


  -- this is ONLY acceptable for simulations;
  -- computing these differences is TOO expensive for synthesis
  in_range <= ( (to_integer(signed(addr(HI_SEL_BITS downto LO_SEL_BITS)))
                 >= 
                 RAM_ADDR_BOTTOM)
                and
                (to_integer(signed(addr(HI_SEL_BITS downto LO_SEL_BITS)))
                 <
                 RAM_ADDR_TOP)
              );

  aVal <= '0' when (rst = '1' and cpu_d_aVal = '0' and in_range) else '1';

  dev_select <= b"0001" when (cpu_d_aVal = '0' and in_range) else b"0000";

  assert true --  cpu_d_aVal = '1'
    report  "e "  & SLV32HEX(addr) & 
    " addr " & SLV2str(addr(15 downto 0)) & LF & 
    " LO_AD " & integer'image(LO_ADDR) &
    " HI_AD " & integer'image(HI_ADDR) &
    " a_hi "    & SLV2STR(a_hi) &
    " a_lo "    & SLV2STR(a_lo) &
    " a_bits "  & SLV2STR(a_bits) &
    " a_mask "  & SLV32HEX(a_mask) & LF &
    " LO_RAM " & integer'image(LO_RAM) &
    " HI_RAM " & integer'image(HI_RAM) &
    " r_hi "    & SLV2STR(r_hi) &
    " r_lo "    & SLV2STR(r_lo) &
    " r_mask "  & SLV32HEX(r_mask)
    severity NOTE;
  
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- busError address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity busError_addr_decode is          -- CPU side triggers access
  port (rst         : in  std_logic;
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  reg32;        -- CPU address
        d_busError  : out std_logic);   -- decoded address not in range (act=0)
end entity busError_addr_decode;

architecture behavioral of busError_addr_decode is

  constant all_0  : std_logic_vector(31 downto 0) := (others=>'0');

  -- I/O constants
  constant IO_RANGE : integer := IO_ADDR_RANGE * IO_MAX_NUM_DEVS;
  constant LO_DEV : natural := 0;
  constant HI_DEV : natural := log2_ceil(IO_RANGE-1);

  constant x_hi   : std_logic_vector(31 downto HI_DEV)  := (others=>'1');
  constant x_lo   : std_logic_vector(HI_DEV-1 downto 0) := (others=>'0');
  constant x_mask : std_logic_vector := x_hi & x_lo;  -- 1..10..0

  -- RAM constants
  constant LO_ADDR : natural := log2_ceil(DATA_BASE_ADDR);
  constant HI_ADDR : natural := log2_ceil(DATA_BASE_ADDR + DATA_MEM_SZ - 1);
    
  constant a_hi   : std_logic_vector(31 downto HI_ADDR+1) := (others=>'0');
  constant a_lo   : std_logic_vector(LO_ADDR-1 downto 0)  := (others=>'0');
  constant a_bits : std_logic_vector(HI_ADDR downto LO_ADDR) := (others=>'1');
  constant a_mask : std_logic_vector := a_hi & a_bits & a_lo;  -- 0..0110..0

  constant LO_RAM : natural := 0;
  constant HI_RAM : natural := log2_ceil(DATA_MEM_SZ-1);
  constant r_hi   : std_logic_vector(31 downto HI_RAM+1)   := (others=>'1');
  constant r_lo   : std_logic_vector(HI_RAM downto LO_RAM) := (others=>'0');
  constant r_mask : std_logic_vector := r_hi & r_lo;  -- 1..10..0
    
  signal in_range, io_in_range : boolean;

begin

  in_range <= ( rst = '1' and
                ((addr and a_mask) = x_DATA_BASE_ADDR) and
                ((addr and r_mask) = x_DATA_BASE_ADDR) );

  io_in_range <= ( (rst = '1') and ((addr and x_mask) = x_IO_BASE_ADDR) );

  
  d_busError <= '0' when ( (rst = '1') and (cpu_d_aVal = '0') and
                           (not(in_range) and not(io_in_range)) ) else '1';

  
  assert true -- cpu_d_aVal = '1'
    report  "e "  & SLV32HEX(addr) & 
    " addr " & SLV2str(addr(15 downto 0)) & LF & 
    " LO_AD " & integer'image(LO_ADDR) &
    " HI_AD " & integer'image(HI_ADDR) &
    " a_hi "    & SLV2STR(a_hi) &
    " a_lo "    & SLV2STR(a_lo) &
    " a_bits "  & SLV2STR(a_bits) &
    " a_mask "  & SLV32HEX(a_mask) & LF &
    " LO_RAM " & integer'image(LO_RAM) &
    " HI_RAM " & integer'image(HI_RAM) &
    " r_hi "    & SLV2STR(r_hi) &
    " r_lo "    & SLV2STR(r_lo) &
    " r_mask "  & SLV32HEX(r_mask)
    severity NOTE;
  
  assert true -- cpu_d_aVal = '1' and io_busError
    report  "e "  & SLV32HEX(addr) & 
    " addr " & SLV2str(addr(15 downto 0)) & LF & 
    " x_hi "    & SLV2STR(x_hi) &
    " x_lo "    & SLV2STR(x_lo) &
    " x_mask "  & SLV32HEX(x_mask) & LF &
    " LO_DEV " & integer'image(LO_DEV) &
    " HI_DEV " & integer'image(HI_DEV)
    severity NOTE;
  
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- I/O address decoding 
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity io_addr_decode is                -- CPU side triggers access
  port (clk,rst     : in  std_logic;    -- clk sparates back-to-back refs
        cpu_d_aVal  : in  std_logic;    -- CPU data addr valid (active=0)
        addr        : in  reg32;        -- CPU address
        dev_select  : out reg4;         -- select input to CPU
        print_sel   : out std_logic;    -- std_out (integer)   (act=0)
        stdout_sel  : out std_logic;    -- std_out (character) (act=0)
        stdin_sel   : out std_logic;    -- std_inp (character)  (act=0)
        read_sel    : out std_logic;    -- file read  (act=0)
        write_sel   : out std_logic;    -- file write (act=0)
        counter_sel : out std_logic;    -- interrupt counter (act=0)
        FPU_sel     : out std_logic;    -- floating point unit (act=0)
        UART_sel    : out std_logic;    -- floating point unit (act=0)
        SSTATS_sel  : out std_logic;    -- system statistics (act=0)
        dsp7seg_sel : out std_logic;    -- 7 segments display (act=0)
        keybd_sel   : out std_logic;    -- telephone keyboard (act=0)
        lcd_sel     : out std_logic;    -- telephone keyboard (act=0)
        not_waiting : in  std_logic);   -- no other device is waiting
end entity io_addr_decode;

architecture behavioral of io_addr_decode is
  constant LO_SEL_ADDR : integer := log2_ceil(IO_ADDR_RANGE);
  constant HI_SEL_ADDR : integer := LO_SEL_ADDR + (IO_MAX_NUM_DEVS - 1);

  constant IO_RANGE : integer := IO_ADDR_RANGE * IO_MAX_NUM_DEVS;
  constant LO_ADDR  : integer := log2_ceil(IO_BASE_ADDR);
  constant HI_ADDR  : integer := log2_ceil(IO_BASE_ADDR + IO_RANGE - 1);
  constant in_r : std_logic_vector(HI_ADDR downto LO_ADDR) := (others => '1');
  constant ng_r : std_logic_vector(HI_ADDR downto LO_ADDR) := (others => '0');
  constant oth  : std_logic_vector(HI_SEL_BITS downto HI_ADDR+1):=(others=>'1');
  constant ng_o : std_logic_vector(HI_SEL_BITS downto HI_ADDR+1):=(others=>'0');
  constant all_0  : std_logic_vector(31 downto 0)         := (others=>'0');

  -- I/O constants
  constant LO_DEV : natural := 0;
  constant HI_DEV : natural := log2_ceil(IO_RANGE-1);

  constant x_hi   : std_logic_vector(31 downto HI_DEV)  := (others=>'1');
  constant x_lo   : std_logic_vector(HI_DEV-1 downto 0) := (others=>'0');
  constant x_mask : std_logic_vector := x_hi & x_lo;  -- 1..10..0

  signal in_range : boolean;
  signal aVal : std_logic;
  signal dev  : integer;                    -- DEBUGGING only
begin

  -- in_range <= ((addr and x_mask) = x_IO_BASE_ADDR);
  
  in_range <= ((addr(HI_ADDR downto LO_ADDR) and in_r) /= ng_r) and
              ((addr(HI_SEL_BITS downto HI_ADDR+1) and oth) = ng_o);

  dev <= to_integer(signed(addr(HI_SEL_ADDR downto LO_SEL_ADDR)));
  
  aVal <= '0' when ( cpu_d_aVal = '0' and rst = '1' and not_waiting = '1' and
                     in_range ) else '1';
  
  U_decode: process(clk, aVal, addr, dev)
    variable dev_sel    : reg4;
    constant is_noise   : integer := 0;
    constant is_print   : integer := 2;
    constant is_stdout  : integer := 3;
    constant is_stdin   : integer := 4;
    constant is_read    : integer := 5;
    constant is_write   : integer := 6;
    constant is_count   : integer := 7;
    constant is_FPU     : integer := 8;
    constant is_UART    : integer := 9;
    constant is_SSTATS  : integer := 10;
    constant is_dsp7seg : integer := 11;
    constant is_keybd   : integer := 12;
    constant is_lcd     : integer := 13;
  begin

    print_sel   <= '1';
    stdout_sel  <= '1';
    stdin_sel   <= '1';
    read_sel    <= '1';
    write_sel   <= '1';
    counter_sel <= '1';
    FPU_sel     <= '1';
    UART_sel    <= '1';
    SSTATS_sel  <= '1';
    dsp7seg_sel <= '1';
    keybd_sel   <= '1';
    lcd_sel     <= '1';

    case dev is -- to_integer(signed(addr(HI_ADDR downto LO_ADDR))) is
      when  0 => dev_sel     := std_logic_vector(to_signed(is_print, 4));
                 print_sel   <= aVal or clk;
      when  1 => dev_sel     := std_logic_vector(to_signed(is_stdout, 4));
                 stdout_sel  <= aVal or clk;
      when  2 => dev_sel     := std_logic_vector(to_signed(is_stdin, 4));
                 stdin_sel   <= aVal or clk;
      when  3 => dev_sel     := std_logic_vector(to_signed(is_read, 4));
                 read_sel    <= aVal or clk;
      when  4 => dev_sel     := std_logic_vector(to_signed(is_write, 4));
                 write_sel   <= aVal or clk;
      when  5 => dev_sel     := std_logic_vector(to_signed(is_count, 4));
                 counter_sel <= aVal;
      when  6 => dev_sel     := std_logic_vector(to_signed(is_FPU, 4));
                 FPU_sel     <= aVal;
      when  7 => dev_sel     := std_logic_vector(to_signed(is_UART, 4));
                 UART_sel    <= aVal;
      when  8 => dev_sel     := std_logic_vector(to_signed(is_SSTATS, 4));
                 SSTATS_sel  <= aVal;
      when  9 => dev_sel     := std_logic_vector(to_signed(is_dsp7seg, 4));
                 dsp7seg_sel <= aVal;
      when 10 => dev_sel     := std_logic_vector(to_signed(is_keybd, 4));
                 keybd_sel   <= aVal;
      when 11 => dev_sel     := std_logic_vector(to_signed(is_lcd, 4));
                 lcd_sel     <= aVal;
      when others => dev_sel := std_logic_vector(to_signed(is_noise, 4));
    end case;
    -- assert false report "IO_addr "& SLV32HEX(addr);--DEBUG

    if aVal = '0' then
      dev_select <= dev_sel;
    else
      dev_select <= std_logic_vector(to_signed(is_noise, 4));
    end if;
    
  end process U_decode;
      
end architecture behavioral;
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- --------------------------------------------------------------
configuration CFG_TB of TB_CMIPS is
	for TB
        end for;
end configuration CFG_TB;
-- --------------------------------------------------------------

