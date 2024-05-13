library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.std_logic_arith.all;
  use work.recop_types.all;
  use work.opcodes;
  use work.mux_select_constants.all;

entity testbench_control_unit_register is
  port (
    t_alu_op2_sel                : out   std_logic_vector(1 downto 0);
    t_jump_select                : out   std_logic;
    t_DPCRwrite_enable           : out   std_logic;
    t_dmr_enable                 : out   std_logic;
    t_rz_register_write_enable   : out   std_logic;
    t_rx_register_write_enable   : out   std_logic;
    t_alu_reg_write_enable       : out   std_logic;
    t_sop_write_enable           : out   std_logic;
    t_zero_reg_reset             : out   std_logic;
    t_dm_write_enable            : out   std_logic;
    t_dpcr_select                : out   std_logic;
    t_alu_op                     : out   std_logic_vector(1 downto 0);
    t_dm_addr_select             : out   std_logic;
    t_register_file_write_enable : out   std_logic;
    t_alu_op1_sel                : out   std_logic_vector(1 downto 0);
    t_reg_write_select           : out   std_logic_vector(1 downto 0);
    t_zero_write_enable          : out   std_logic;
    t_sip_ld                     : out   std_logic;
    t_pm_read_enable             : inout std_logic;
    t_ir_write_enable            : out   std_logic;
    t_pc_write_enable            : out   std_logic;
    t_pc_branch_conditional      : out   std_logic;
    t_pc_input_select            : out   std_logic_vector(1 downto 0);
    t_state_decode_fail          : out   std_logic
  );
end entity;

architecture test of testbench_control_unit_register is
  signal t_clock           : std_logic := '0';
  signal t_enable          : std_logic := '1';
  signal t_reset           : std_logic;
  signal t_addressing_mode : std_logic_vector(1 downto 0);
  signal t_opcode          : std_logic_vector(5 downto 0);
  signal t_dprr            : std_logic;

begin
  DUT: entity work.control_unit
    port map (
      clock                             => t_clock,
      enable                            => t_enable,
      reset                             => t_reset,
      addressing_mode                   => t_addressing_mode,
      opcode                            => t_opcode,
      dprr                              => t_dprr,
      alu_op2_sel                       => t_alu_op2_sel,
      jump_select                       => t_jump_select,
      DPCRwrite_enable                  => t_DPCRwrite_enable,
      dmr_write_enable                  => t_dmr_enable,
      rz_register_write_enable          => t_rz_register_write_enable,
      rx_register_write_enable          => t_rx_register_write_enable,
      alu_register_write_enable         => t_alu_reg_write_enable,
      ssop                              => t_sop_write_enable,
      z_register_reset                  => t_zero_reg_reset,
      data_memory_write_enable          => t_dm_write_enable,
      dpcr_select                       => t_dpcr_select,
      alu_op_sel                        => t_alu_op,
      data_memory_address_select        => t_dm_addr_select,
      register_file_write_enable        => t_register_file_write_enable,
      alu_op1_sel                       => t_alu_op1_sel,
      register_file_write_select        => t_reg_write_select,
      z_register_write_enable           => t_zero_write_enable,
      lsip                              => t_sip_ld,
      program_memory_read_enable        => t_pm_read_enable,
      instruction_register_write_enable => t_ir_write_enable,
      pc_write_enable                   => t_pc_write_enable,
      pc_branch_conditional             => t_pc_branch_conditional,
      pc_input_select                   => t_pc_input_select,

      state_decode_fail                 => t_state_decode_fail
    );

  -- * Generating Signals

  -- Clock
  process
  begin
    wait for 10 ns;
    t_clock <= '0';
    wait for 10 ns;
    t_clock <= '1';
  end process;

  -- Opcode 
  process
  begin
    t_opcode <= opcodes.andr;
    t_addressing_mode <= opcodes.am_register;
    wait for 10 ns;
    wait until rising_edge(t_pm_read_enable);

    t_opcode <= opcodes.subvr;
    t_addressing_mode <= opcodes.am_register;
    wait for 10 ns;
    wait until rising_edge(t_pm_read_enable);

    t_opcode <= opcodes.ldr;
    t_addressing_mode <= opcodes.am_register;
    wait for 10 ns;
    wait until rising_edge(t_pm_read_enable);

    t_opcode <= opcodes.orr;
    t_addressing_mode <= opcodes.am_register;
    wait for 10 ns;
    wait until rising_edge(t_pm_read_enable);

    t_opcode <= opcodes.str;
    t_addressing_mode <= opcodes.am_register;
    wait for 10 ns;
    wait until rising_edge(t_pm_read_enable);

    t_enable <= '0';
    wait;
  end process;
end architecture;
