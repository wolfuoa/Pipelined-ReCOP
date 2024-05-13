library ieee;
  use ieee.std_logic_1164.all;
  use IEEE.numeric_std.all;

entity instruction_register is
  port (
    clock           : in  std_logic;
    reset           : in  std_logic;
    write_enable    : in  std_logic;
    instruction     : in  std_logic_vector(31 downto 0);
    addressing_mode : out std_logic_vector(1 downto 0);
    opcode          : out std_logic_vector(5 downto 0);
    rz              : out std_logic_vector(3 downto 0);
    rx              : out std_logic_vector(3 downto 0);
    immediate       : out std_logic_vector(15 downto 0)
  );
end entity;

architecture beh of instruction_register is
  signal next_instruction : std_logic_vector(31 downto 0) := (others => '0');
begin
  process (clock, reset)
  begin
    if reset = '1' then
      next_instruction <= (others => '0');
    elsif rising_edge(clock) then
      if write_enable = '1' then
        next_instruction <= instruction;
      else
        next_instruction <= next_instruction;
      end if;
    end if;
  end process;

  addressing_mode <= next_instruction(31 downto 30);
  opcode          <= next_instruction(29 downto 24);
  rz              <= next_instruction(23 downto 20);
  rx              <= next_instruction(19 downto 16);
  immediate       <= next_instruction(15 downto 0);
end architecture;
