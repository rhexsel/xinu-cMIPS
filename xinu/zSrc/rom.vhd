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


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- syncronous ROM; MIPS executable defined as constant, word-indexed
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.p_wires.all;
use work.p_memory.all;

entity fpga_ROM is
  generic (LOAD_FILE_NAME : string := "prog.bin");  -- not used with FPGA
  port (rst    : in    std_logic;
        clk    : in    std_logic;
        sel    : in    std_logic;         -- active in '0'
        rdy    : out   std_logic;         -- active in '0'
        strobe : in    std_logic;
        addr   : in    reg32;
        data   : out   reg32);
  constant INST_ADDRS_BITS : natural := log2_ceil(INST_MEM_SZ);
  subtype rom_address is natural range 0 to ((INST_MEM_SZ / 4) - 1);
end entity fpga_ROM;

architecture rtl of fpga_ROM is

  component wait_states is
    generic (NUM_WAIT_STATES :integer := 0);
    port(rst     : in  std_logic;
         clk     : in  std_logic;
         sel     : in  std_logic;         -- active in '0'
         waiting : out std_logic);        -- active in '1'
  end component wait_states;

  component single_port_rom is
    generic (N_WORDS : integer);
    port (address : in rom_address;
          clken   : in std_logic;
          clock   : in std_logic;
          q       : out std_logic_vector);
  end component single_port_rom;

  signal instrn : reg32;
  signal index  : rom_address := 0;
  signal waiting, clken : std_logic;
  
begin  -- rtl

  U_BUS_WAIT: wait_states generic map (ROM_WAIT_STATES)
    port map (rst, clk, sel, waiting);

  rdy <= not(waiting);

  clken  <= not(sel);
    
  -- >>2 = /4: byte addressed but word indexed
  index <= to_integer(unsigned(addr((INST_ADDRS_BITS-1) downto 2)));

  U_ROM: single_port_rom generic map (INST_MEM_SZ / 4)
    port map (index, clken, strobe, instrn);

  U_ROM_ACCESS: process (strobe,instrn,sel)
  begin
    if sel = '0' then
      data <= instrn;
      assert (index >= 0) and (index < INST_MEM_SZ/4)
        report "rom index out of bounds: " & natural'image(index)
        severity failure;
      -- assert false -- DEBUG
      --   report "romRD["& natural'image(index) &"]="& SLV32HEX(data); 
    else
      data <= (others => 'X');
    end if;
  end process U_ROM_ACCESS;

end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Adapted from Altera's design for a ROM that may be synthesized
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.p_wires.all;

entity single_port_rom is
  generic (N_WORDS : integer := 32);
  port (address : in natural range 0 to (N_WORDS - 1);
        clken   : in std_logic;
        clock   : in std_logic;
        q       : out reg32);
end entity;

architecture rtl of single_port_rom is

  -- Build a 2-D array type for the RoM
  subtype word_t is std_logic_vector(31 downto 0);
  type memory_t is array(0 to (N_WORDS-1)) of word_t;

  -- assemble.sh -v mac_lcd.s |\
  -- sed -e '1,6d' -e '/^$/d' -e '/^ /!d' -e 's:\t: :g' \
  -- -e 's#\(^ *[a-f0-9]*:\) *\(........\)  *\(.*\)$#x"\2", -- \1 \3#' \
  -- -e '$s:,: :' 
  
  constant test_prog : memory_t := (

x"00000000", --    0: nop
x"3c0f0f00", --    4: lui $15,0xf00
x"35ef0120", --    8: ori $15,$15,0x120
x"24100001", --    c: li $16,1
x"adf00000", --   10: sw $16,0($15)
x"3c040009", --   14: lui $4,0x9
x"34848968", --   18: ori $4,$4,0x8968
x"0c0000b7", --   1c: jal 2dc <delay>
x"00000000", --   20: nop
x"3c1a0f00", --   24: lui $26,0xf00
x"375a0160", --   28: ori $26,$26,0x160
x"24130030", --   2c: li $19,48
x"af530000", --   30: sw $19,0($26)
x"24040177", --   34: li $4,375
x"0c0000b7", --   38: jal 2dc <delay>
x"00000000", --   3c: nop
x"24130030", --   40: li $19,48
x"af530000", --   44: sw $19,0($26)
x"24040177", --   48: li $4,375
x"0c0000b7", --   4c: jal 2dc <delay>
x"00000000", --   50: nop
x"24130039", --   54: li $19,57
x"af530000", --   58: sw $19,0($26)
x"24040177", --   5c: li $4,375
x"0c0000b7", --   60: jal 2dc <delay>
x"00000000", --   64: nop
x"24130014", --   68: li $19,20
x"af530000", --   6c: sw $19,0($26)
x"24040177", --   70: li $4,375
x"0c0000b7", --   74: jal 2dc <delay>
x"00000000", --   78: nop
x"24130070", --   7c: li $19,112
x"af530000", --   80: sw $19,0($26)
x"24040177", --   84: li $4,375
x"0c0000b7", --   88: jal 2dc <delay>
x"00000000", --   8c: nop
x"24130056", --   90: li $19,86
x"af530000", --   94: sw $19,0($26)
x"24040177", --   98: li $4,375
x"0c0000b7", --   9c: jal 2dc <delay>
x"00000000", --   a0: nop
x"2413006d", --   a4: li $19,109
x"af530000", --   a8: sw $19,0($26)
x"24040177", --   ac: li $4,375
x"0c0000b7", --   b0: jal 2dc <delay>
x"00000000", --   b4: nop
x"24100002", --   b8: li $16,2
x"adf00000", --   bc: sw $16,0($15)
x"3c0400be", --   c0: lui $4,0xbe
x"3484bc20", --   c4: ori $4,$4,0xbc20
x"0c0000b7", --   c8: jal 2dc <delay>
x"00000000", --   cc: nop
x"3c040026", --   d0: lui $4,0x26
x"348425a0", --   d4: ori $4,$4,0x25a0
x"0c0000b7", --   d8: jal 2dc <delay>
x"00000000", --   dc: nop
x"24100003", --   e0: li $16,3
x"adf00000", --   e4: sw $16,0($15)
x"3c0400be", --   e8: lui $4,0xbe
x"3484bc20", --   ec: ori $4,$4,0xbc20
x"0c0000b7", --   f0: jal 2dc <delay>
x"00000000", --   f4: nop
x"3c1a0f00", --   f8: lui $26,0xf00
x"375a0160", --   fc: ori $26,$26,0x160
x"2413000f", --  100: li $19,15
x"af530000", --  104: sw $19,0($26)
x"24040177", --  108: li $4,375
x"0c0000b7", --  10c: jal 2dc <delay>
x"00000000", --  110: nop
x"24130006", --  114: li $19,6
x"af530000", --  118: sw $19,0($26)
x"24040177", --  11c: li $4,375
x"0c0000b7", --  120: jal 2dc <delay>
x"00000000", --  124: nop
x"24100004", --  128: li $16,4
x"adf00000", --  12c: sw $16,0($15)
x"3c0400be", --  130: lui $4,0xbe
x"3484bc20", --  134: ori $4,$4,0xbc20
x"0c0000b7", --  138: jal 2dc <delay>
x"00000000", --  13c: nop
x"24130001", --  140: li $19,1
x"af530000", --  144: sw $19,0($26)
x"24040177", --  148: li $4,375
x"0c0000b7", --  14c: jal 2dc <delay>
x"00000000", --  150: nop
x"24130080", --  154: li $19,128
x"af530000", --  158: sw $19,0($26)
x"24040177", --  15c: li $4,375
x"0c0000b7", --  160: jal 2dc <delay>
x"00000000", --  164: nop
x"24100005", --  168: li $16,5
x"adf00000", --  16c: sw $16,0($15)
x"3c0400be", --  170: lui $4,0xbe
x"3484bc20", --  174: ori $4,$4,0xbc20
x"0c0000b7", --  178: jal 2dc <delay>
x"00000000", --  17c: nop
x"8f530000", --  180: lw $19,0($26)
x"00000000", --  184: nop
x"32730080", --  188: andi $19,$19,0x80
x"1660fffc", --  18c: bnez $19,180 <check>
x"00000000", --  190: nop
x"02608021", --  194: move $16,$19
x"adf00000", --  198: sw $16,0($15)
x"3c0400be", --  19c: lui $4,0xbe
x"3484bc20", --  1a0: ori $4,$4,0xbc20
x"0c0000b7", --  1a4: jal 2dc <delay>
x"00000000", --  1a8: nop
x"24130080", --  1ac: li $19,128
x"af530000", --  1b0: sw $19,0($26)
x"24040177", --  1b4: li $4,375
x"0c0000b7", --  1b8: jal 2dc <delay>
x"00000000", --  1bc: nop
x"3c046c6c", --  1c0: lui $4,0x6c6c
x"34846548", --  1c4: ori $4,$4,0x6548
x"0c000097", --  1c8: jal 25c <send>
x"00000000", --  1cc: nop
x"3c046f77", --  1d0: lui $4,0x6f77
x"3484206f", --  1d4: ori $4,$4,0x206f
x"0c000097", --  1d8: jal 25c <send>
x"00000000", --  1dc: nop
x"3c042164", --  1e0: lui $4,0x2164
x"34846c72", --  1e4: ori $4,$4,0x6c72
x"0c000097", --  1e8: jal 25c <send>
x"00000000", --  1ec: nop
x"24100007", --  1f0: li $16,7
x"adf00000", --  1f4: sw $16,0($15)
x"3c0400be", --  1f8: lui $4,0xbe
x"3484bc20", --  1fc: ori $4,$4,0xbc20
x"0c0000b7", --  200: jal 2dc <delay>
x"00000000", --  204: nop
x"241300c0", --  208: li $19,192
x"af530000", --  20c: sw $19,0($26)
x"24040177", --  210: li $4,375
x"0c0000b7", --  214: jal 2dc <delay>
x"00000000", --  218: nop
x"3c046961", --  21c: lui $4,0x6961
x"34847320", --  220: ori $4,$4,0x7320
x"0c000097", --  224: jal 25c <send>
x"00000000", --  228: nop
x"3c044d63", --  22c: lui $4,0x4d63
x"34842064", --  230: ori $4,$4,0x2064
x"0c000097", --  234: jal 25c <send>
x"00000000", --  238: nop
x"3c042053", --  23c: lui $4,0x2053
x"34845049", --  240: ori $4,$4,0x5049
x"0c000097", --  244: jal 25c <send>
x"00000000", --  248: nop
x"24100008", --  24c: li $16,8
x"adf00000", --  250: sw $16,0($15)
x"08000095", --  254: j 254 <end>
x"00000000", --  258: nop
x"3c1a0f00", --  25c: lui $26,0xf00
x"375a0160", --  260: ori $26,$26,0x160
x"af440004", --  264: sw $4,4($26)
x"00042202", --  268: srl $4,$4,0x8
x"240500fa", --  26c: li $5,250
x"24a5ffff", --  270: addiu $5,$5,-1
x"00000000", --  274: nop
x"14a0fffd", --  278: bnez $5,270 <delay0>
x"00000000", --  27c: nop
x"af440004", --  280: sw $4,4($26)
x"00042202", --  284: srl $4,$4,0x8
x"240500fa", --  288: li $5,250
x"24a5ffff", --  28c: addiu $5,$5,-1
x"00000000", --  290: nop
x"14a0fffd", --  294: bnez $5,28c <delay1>
x"00000000", --  298: nop
x"af440004", --  29c: sw $4,4($26)
x"00042202", --  2a0: srl $4,$4,0x8
x"240500fa", --  2a4: li $5,250
x"24a5ffff", --  2a8: addiu $5,$5,-1
x"00000000", --  2ac: nop
x"14a0fffd", --  2b0: bnez $5,2a8 <delay2>
x"00000000", --  2b4: nop
x"af440004", --  2b8: sw $4,4($26)
x"00000000", --  2bc: nop
x"240500fa", --  2c0: li $5,250
x"24a5ffff", --  2c4: addiu $5,$5,-1
x"00000000", --  2c8: nop
x"14a0fffd", --  2cc: bnez $5,2c4 <delay3>
x"00000000", --  2d0: nop
x"03e00008", --  2d4: jr $31
x"00000000", --  2d8: nop
x"2484ffff", --  2dc: addiu $4,$4,-1
x"00000000", --  2e0: nop
x"1480fffd", --  2e4: bnez $4,2dc <delay>
x"00000000", --  2e8: nop
x"03e00008", --  2ec: jr $31
x"00000000", --  2f0: nop
x"00000000", --  2f4: nop
x"00000000", --  2f8: nop
x"00000000", --  2fc: nop
x"00000000", --  300: nop
x"00000000", --  304: nop
x"00000000", --  308: nop
x"00000000", --  30c: nop
x"00000000", --  310: nop
x"00000000", --  314: nop
x"00000000", --  318: nop
x"00000000", --  31c: nop
x"00000000", --  320: nop
x"00000000", --  324: nop
x"00000000", --  328: nop
x"00000000", --  32c: nop
x"00000000", --  330: nop
x"00000000", --  334: nop
x"00000000", --  338: nop
x"00000000", --  33c: nop
x"00000000", --  340: nop
x"00000000", --  344: nop
x"00000000", --  348: nop
x"00000000", --  34c: nop
x"00000000", --  350: nop
x"00000000", --  354: nop
x"00000000", --  358: nop
x"00000000", --  35c: nop
x"00000000", --  360: nop
x"00000000", --  364: nop
x"00000000", --  368: nop
x"00000000", --  36c: nop
x"00000000", --  370: nop
x"00000000", --  374: nop
x"00000000", --  378: nop
x"00000000", --  37c: nop
x"00000000", --  380: nop
x"00000000", --  384: nop
x"00000000", --  388: nop
x"00000000", --  38c: nop
x"00000000", --  390: nop
x"00000000", --  394: nop
x"00000000", --  398: nop
x"00000000", --  39c: nop
x"00000000", --  3a0: nop
x"00000000", --  3a4: nop
x"00000000", --  3a8: nop
x"00000000", --  3ac: nop
x"00000000", --  3b0: nop
x"00000000", --  3b4: nop
x"00000000", --  3b8: nop
x"00000000", --  3bc: nop
x"00000000", --  3c0: nop
x"00000000", --  3c4: nop
x"00000000", --  3c8: nop
x"00000000", --  3cc: nop
x"00000000", --  3d0: nop
x"00000000", --  3d4: nop
x"00000000", --  3d8: nop
x"00000000", --  3dc: nop
x"00000000", --  3e0: nop
x"00000000", --  3e4: nop
x"00000000", --  3e8: nop
x"00000000", --  3ec: nop
x"00000000", --  3f0: nop
x"00000000", --  3f4: nop
x"00000000", --  3f8: nop
x"00000000"  --  3fc: nop
    
    
);
   

  function init_rom
    return memory_t is
    variable tmp : memory_t := (others => (others => '0'));
    variable i_addr : integer;
  begin
    for addr_pos in test_prog'range loop
      tmp(addr_pos) := test_prog(addr_pos);
      -- i_addr := addr_pos;
    end loop;

    for addr_pos in test_prog'high to (N_WORDS - 1) loop
      tmp(addr_pos) := x"00000000";      -- nop
    end loop;
    return tmp;
  end init_rom;

  -- Declare the ROM signal and specify a default value. Quartus II
  -- will create a memory initialization file (ROM.mif) based on the 
  -- default value.
  signal rom : memory_t := init_rom;

begin
  
  process(clock,clken)
  begin
    if(clken = '1' and rising_edge(clock)) then
      q <= rom(address);
    end if;
  end process;
  
end rtl;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
