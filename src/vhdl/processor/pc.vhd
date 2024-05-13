-- recop_pc.vhd
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;

  use work.mux_select_constants.all;

entity pc is
  generic (
    START_ADDR : std_logic_vector(15 downto 0) := (others => '0')
  );
  port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    write_enable    : in  std_logic;
    -- see various_constants.vhd for options for this input
    pc_input_select : in  std_logic_vector(1 downto 0);
    jump_address    : in  std_logic_vector(15 downto 0);
    alu_out         : in  std_logic_vector(15 downto 0);
    alu             : in  std_logic_vector(15 downto 0);

    pc              : out std_logic_vector(15 downto 0)
  );
end entity;

architecture arch of pc is
  signal pc_internal : std_logic_vector(15 downto 0) := START_ADDR;

  signal pc_internal_next : std_logic_vector(15 downto 0) := START_ADDR;
begin

  with pc_input_select select pc_internal_next <=
    alu_out             when pc_input_select_aluout,
    jump_address        when pc_input_select_jmp,
    alu                 when pc_input_select_alu,
        (others => 'X') when others;

  pc <= pc_internal;

  process (clock)
  begin
    if reset = '1' then
      pc_internal <= START_ADDR;
    elsif rising_edge(clock) then
      if write_enable = '1' then
        pc_internal <= pc_internal_next;
      else
        pc_internal <= pc_internal;
      end if;
    end if;
  end process;

end architecture; -- arch
