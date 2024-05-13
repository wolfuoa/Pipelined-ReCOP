library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;

entity testbench_data_memory is
end entity;

architecture arch of testbench_data_memory is
  signal t_clock        : std_logic;
  signal t_reset        : std_logic;
  signal t_write_enable : std_logic;

  signal t_data_in  : std_logic_vector(15 downto 0);
  signal t_data_out : std_logic_vector(15 downto 0);

  signal t_address : std_logic_vector(15 downto 0);

  signal not_t_clock : std_logic;
begin
  not_t_clock <= not t_clock;
  dut: entity work.data_memory
    port map (
      clock        => not_t_clock,
      reset        => t_reset,
      data_in      => t_data_in,
      write_enable => t_write_enable,
      address      => t_address,
      data_out     => t_data_out
    );

  process
  begin
    wait for 20 ns;
    t_write_enable <= '1';
    t_address <= x"0000";
    t_data_in <= x"0000";
    wait for 10 ns;
    t_address <= x"0001";
    t_data_in <= x"1111";
    wait for 20 ns;
    t_address <= x"0002";
    t_data_in <= x"2222";
    wait for 20 ns;
    t_address <= x"0003";
    t_data_in <= x"3333";
    wait for 20 ns;
    t_address <= x"0004";
    t_data_in <= x"4444";
    wait for 20 ns;
    t_write_enable <= '0';
    t_address <= x"0000";
    t_data_in <= x"BABE";
    wait for 20 ns;
    t_address <= x"0001";
    wait for 20 ns;
    t_address <= x"0002";
    wait for 20 ns;
    t_address <= x"0003";
    wait for 20 ns;
    t_address <= x"0004";
  end process;

  process
  begin
    t_clock <= '1';
    wait for 10 ns;
    t_clock <= '0';
    wait for 10 ns;
  end process;

  -- Initialise
  process
  begin
    t_reset <= '1';
    wait for 20 ns;
    t_reset <= '0';
    wait;
  end process;

end architecture;
