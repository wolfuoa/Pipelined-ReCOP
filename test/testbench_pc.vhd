library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;
  use work.mux_select_constants;

entity testbench_pc is
  port (
    signal out_pc : out std_logic_vector(15 downto 0)
  );
end entity;

architecture arch of testbench_pc is
  signal t_clock           : std_logic                    := '0';
  signal t_write_enable    : std_logic                    := '0';
  signal t_reset           : std_logic                    := '0';
  signal t_pc_input_select : std_logic_vector(1 downto 0) := "00";

  signal jump_address : std_logic_vector(15 downto 0);
  signal alu_out      : std_logic_vector(15 downto 0);
  signal t_alu        : std_logic_vector(15 downto 0);
  signal pc           : std_logic_vector(15 downto 0);
begin

  out_pc <= pc;

  DUT: entity work.pc
    port map (
      clock           => t_clock,
      reset           => t_reset,
      write_enable    => t_write_enable,
      pc_input_select => t_pc_input_select,
      jump_address    => jump_address,
      alu_out         => alu_out,
      alu             => t_alu,
      pc              => pc
    );

  CLOCK: process
  begin
    wait for 10 ns;
    t_clock <= '1';
    wait for 10 ns;
    t_clock <= '0';
  end process;

  process
  begin
    t_pc_input_select <= mux_select_constants.pc_input_select_alu;
    t_alu <= x"BEEF";
    t_write_enable <= '1';
    wait until rising_edge(t_clock);

    t_pc_input_select <= mux_select_constants.pc_input_select_jmp;
    jump_address <= x"B00B";
    t_write_enable <= '1';
    wait until rising_edge(t_clock);

    t_pc_input_select <= mux_select_constants.pc_input_select_aluout;
    alu_out <= x"F00D";
    t_write_enable <= '0';
    wait until rising_edge(t_clock);

    t_reset <= '1';
    wait until rising_edge(t_clock);

    wait;

  end process;

end architecture; -- testbench_recop_pc
