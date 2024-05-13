library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.alu_ops;
  use work.mux_select_constants.all;

entity testbench_alu is
end entity;

architecture arch of testbench_alu is

  signal t_zero          : std_logic;
  signal t_alu_operation : std_logic_vector(1 downto 0);
  signal t_alu_op1_sel   : std_logic_vector(1 downto 0);
  signal t_alu_op2_sel   : std_logic_vector(1 downto 0);
  signal t_rz            : std_logic_vector(15 downto 0);
  signal t_immediate     : std_logic_vector(15 downto 0);
  signal t_pc            : std_logic_vector(15 downto 0);
  signal t_rx            : std_logic_vector(15 downto 0);
  signal t_alu_result    : std_logic_vector(15 downto 0);

begin
  DUT: entity work.alu
    port map (
      zero          => t_zero,
      alu_operation => t_alu_operation,
      alu_op1_sel   => t_alu_op1_sel,
      alu_op2_sel   => t_alu_op2_sel,
      rz            => t_rz,
      immediate     => t_immediate,
      pc            => t_pc,
      rx            => t_rx,
      alu_result    => t_alu_result
    );

  process
  begin
    t_rx <= x"0001";
    t_immediate <= x"0002";
    t_pc <= x"0003";
    t_rx <= x"0004";
    wait for 20 ns;
    -- 2 + 4
    t_alu_op1_sel <= alu_op1_immediate;
    t_alu_op2_sel <= alu_op2_rx;
    t_alu_operation <= alu_ops.alu_add;
    wait for 20 ns;
    -- pc + 1 (3+1)
    t_alu_op1_sel <= alu_op1_pc;
    t_alu_op2_sel <= alu_op2_one;
    t_alu_operation <= alu_ops.alu_add;
    wait for 20 ns;
    t_rx <= x"0002";
    t_immediate <= x"0001";
    -- 2 - 1 
    t_alu_op1_sel <= alu_op1_immediate;
    t_alu_op2_sel <= alu_op2_rx;
    t_alu_operation <= alu_ops.alu_sub;
    wait for 20 ns;
    t_rx <= x"0001";
    t_immediate <= x"0001";
    -- 1 and 1
    t_alu_op1_sel <= alu_op1_immediate;
    t_alu_op2_sel <= alu_op2_rx;
    t_alu_operation <= alu_ops.alu_and;
    wait for 20 ns;
    t_rx <= x"0000";
    t_immediate <= x"0001";
    t_alu_op1_sel <= alu_op1_immediate;
    t_alu_op2_sel <= alu_op2_rx;
    t_alu_operation <= alu_ops.alu_or;
    wait for 20 ns;
    -- 1 and 0
    t_alu_op1_sel <= alu_op1_immediate;
    t_alu_op2_sel <= alu_op2_rx;
    t_alu_operation <= alu_ops.alu_and;
    wait for 20 ns;
  end process;
end architecture;
