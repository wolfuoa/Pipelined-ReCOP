library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.recop_types.all;
use work.opcodes;
use work.mux_select_constants.all;

entity top_level is
    port (
        clock         : in  std_logic;
        enable        : in  std_logic := '1';
        dprr          : in  std_logic_vector(31 downto 0);
        sip_data_in   : in  std_logic_vector(15 downto 0);
        reset         : in  std_logic := '0';
        dpcr_data_out : out std_logic_vector(31 downto 0);
        sop_data_out  : out std_logic_vector(15 downto 0);
    );
end entity;

architecture processor of top_level is

    -------------------------------- IF --------------------------------
    signal IF_addressing_mode            : std_logic_vector(1 downto 0);
    signal IF_opcode                     : std_logic_vector(5 downto 0);
    signal IF_rz_index                   : std_logic_vector(3 downto 0);
    signal IF_rx_index                   : std_logic_vector(3 downto 0);
    signal IF_immediate                  : std_logic_vector(15 downto 0);
    signal IF_register_file_rz_select    : std_logic;
    signal IF_rz                         : std_logic_vector(15 downto 0);
    signal IF_rx                         : std_logic_vector(15 downto 0);
    signal IF_program_memory_address     : std_logic_vector(15 downto 0);
    signal IF_program_memory_data        : std_logic_vector(31 downto 0);
    signal IF_pc                         : std_logic_vector(15 downto 0);

    signal IF_dpcr_write_enable          : std_logic := '0';
    signal IF_dpcr_select                : std_logic := '0';
    signal IF_ssop                       : std_logic := '0';
    signal IF_jump_select                : std_logic;
    signal IF_register_file_write_select : std_logic_vector(2 downto 0) := "000";
    signal IF_data_memory_data_select    : std_logic_vector(1 downto 0);
    signal IF_data_memory_address_select : std_logic_vector(1 downto 0);
    signal IF_data_memory_write_enable   : std_logic;
    signal IF_z_register_write_enable    : std_logic;
    signal IF_z_register_reset           : std_logic;
    signal IF_alu_op_sel                 : std_logic_vector(1 downto 0);
    signal IF_alu_op1_sel                : std_logic_vector(1 downto 0);
    signal IF_alu_op2_sel                : std_logic_vector(1 downto 0);
    signal IF_register_file_write_enable : std_logic;
    signal IF_pc_branch_conditional      : std_logic;
    signal IF_pc_input_select            : std_logic_vector(1 downto 0);
    signal IF_j                          : std_logic;
    signal IF_present                    : std_logic;
    signal IF_data_memory_address        : std_logic_vector(15 downto 0);
    signal IF_data_memory_data_in        : std_logic_vector(15 downto 0);
    signal IF_data_memory_data_out       : std_logic_vector(15 downto 0);
    signal IF_dprr_clear                 : std_logic;
    signal IF_rz_index                   : std_logic_vector(3 downto 0);
    signal IF_rz                         : std_logic_vector(15 downto 0);
    signal IF_rx                         : std_logic_vector(15 downto 0);
    signal IF_immediate                  : std_logic_vector(15 downto 0);
    signal IF_pc                         : std_logic_vector(15 downto 0);
    --------------------------------------------------------------------

    -------------------------------- EX --------------------------------
    signal EX_dpcr_write_enable          : std_logic := '0';
    signal EX_dpcr_select                : std_logic := '0';
    signal EX_ssop                       : std_logic := '0';
    signal EX_jump_select                : std_logic;
    signal EX_register_file_write_select : std_logic_vector(2 downto 0) := "000";
    signal EX_data_memory_data_select    : std_logic_vector(1 downto 0);
    signal EX_data_memory_address_select : std_logic_vector(1 downto 0);
    signal EX_data_memory_write_enable   : std_logic;
    signal EX_z_register_write_enable    : std_logic;
    signal EX_z_register_reset           : std_logic;
    signal EX_alu_op_sel                 : std_logic_vector(1 downto 0);
    signal EX_alu_op1_sel                : std_logic_vector(1 downto 0);
    signal EX_alu_op2_sel                : std_logic_vector(1 downto 0);
    signal EX_register_file_write_enable : std_logic;
    signal EX_pc_branch_conditional      : std_logic;
    signal EX_pc_input_select            : std_logic_vector(1 downto 0);
    signal EX_j                          : std_logic;
    signal EX_present                    : std_logic;
    signal EX_data_memory_address        : std_logic_vector(15 downto 0);
    signal EX_data_memory_data_in        : std_logic_vector(15 downto 0);
    signal EX_data_memory_data_out       : std_logic_vector(15 downto 0);
    signal EX_dprr_clear                 : std_logic;
    signal EX_rz_index                   : std_logic_vector(3 downto 0);
    signal EX_rz                         : std_logic_vector(15 downto 0);
    signal EX_rx                         : std_logic_vector(15 downto 0);
    signal EX_immediate                  : std_logic_vector(15 downto 0);
    signal EX_pc                         : std_logic_vector(15 downto 0);
    --------------------------------------------------------------------

    -------------------------------- WB --------------------------------
    signal WB_register_file_write_enable : std_logic;
    signal WB_register_file_write_select : std_logic_vector(2 downto 0) := "000";
    signal WB_rz_index                   : std_logic_vector(3 downto 0);
    signal WB_alu_result                 : std_logic_vector(15 downto 0);
    signal WB_data_memory_data_out       : std_logic_vector(15 downto 0);
    signal WB_immediate                  : std_logic_vector(15 downto 0);
    signal WB_max                        : std_logic_vector(15 downto 0);
    signal WB_sip_data_out               : std_logic_vector(15 downto 0);
    --------------------------------------------------------------------
begin

    -- SIGNALS => PIPE_REG_EX -> EX_SIGNALS -> EX_STAGE => PIPE_REG_WB -> WB_STAGE

    decoder : entity work.decode
        port map(
            clock           => clock,
            enable          => enable,
            reset           => reset,
            instruction     => IF_program_memory_data,
            addressing_mode => IF_addressing_mode,
            opcode          => IF_opcode,
            rz              => IF_rz_index,
            rx              => IF_rx_index,
            immediate       => IF_immediate
        );

    control_unit : entity work.control_unit
        port map(
            clock                      => clock,
            enable                     => enable,
            reset                      => reset,

            addressing_mode            => IF_addressing_mode,
            opcode                     => IF_opcode,
            dprr                       => IF_dprr(1),
            dprr_clear                 => IF_dprr_clear,
            dpcr_enable                => IF_dpcr_write_enable,
            dpcr_select                => IF_dpcr_select,
            data_memory_write_enable   => IF_data_memory_write_enable,
            data_memory_address_select => IF_data_memory_address_select,
            data_memory_data_select    => IF_data_memory_data_select,
            ssop_port                  => IF_ssop,
            register_file_write_select => IF_register_file_write_select,
            register_file_write_enable => IF_register_file_write_enable,
            register_file_rz_select    => IF_register_file_rz_select,
            z_register_reset           => IF_z_register_reset,
            z_register_write_enable    => IF_z_register_write_enable,
            alu_op_sel                 => IF_alu_op_sel,
            alu_op1_sel                => IF_alu_op1_sel,
            alu_op2_sel                => IF_alu_op2_sel,
            present                    => IF_present,
            jump_select                => IF_jump_select,
            pc_branch_conditional      => IF_pc_branch_conditional,
            j                          => IF_j,
        );

    pipeline_reg_execute : entity work.pipeline_reg_execute
        port map(
            clock                            => clock,
            enable                           => enable,
            reset                            => reset,
            EX_dpcr_write_enable             => IF_dpcr_write_enable,
            EX_dpcr_select                   => IF_dpcr_select,
            EX_ssop                          => IF_ssop,
            EX_jump_select                   => IF_jump_select,
            EX_register_file_write_select    => IF_register_file_write_select,
            EX_data_memory_data_select       => IF_data_memory_data_select,
            EX_data_memory_address_select    => IF_data_memory_address_select,
            EX_data_memory_write_enable      => IF_data_memory_write_enable,
            EX_z_register_write_enable       => IF_z_register_write_enable,
            EX_z_register_reset              => IF_z_register_reset,
            EX_alu_op_sel                    => IF_alu_op_sel,
            EX_alu_op1_sel                   => IF_alu_op1_sel,
            EX_alu_op2_sel                   => IF_alu_op2_sel,
            EX_register_file_write_enable    => IF_register_file_write_enable,
            EX_pc_branch_conditional         => IF_pc_branch_conditional,
            EX_pc_input_select               => IF_pc_input_select,
            EX_j                             => IF_j,
            EX_present                       => IF_present,
            EX_data_memory_address           => IF_data_memory_address,
            EX_data_memory_data_in           => IF_data_memory_data_in,
            EX_data_memory_data_out          => IF_data_memory_data_out,
            EX_dprr_clear                    => IF_dprr_clear,
            EX_rz_index                      => IF_rz_index,
            EX_rz                            => IF_rz,
            EX_rx                            => IF_rx,
            EX_immediate                     => IF_immediate,
            EX_pc                            => IF_pc,

            EX_WB_dpcr_write_enable          => EX_dpcr_write_enable,
            EX_WB_dpcr_select                => EX_dpcr_select,
            EX_WB_ssop                       => EX_ssop,
            EX_WB_jump_select                => EX_jump_select,
            EX_WB_register_file_write_select => EX_register_file_write_select,
            EX_WB_data_memory_data_select    => EX_data_memory_data_select,
            EX_WB_data_memory_address_select => EX_data_memory_address_select,
            EX_WB_data_memory_write_enable   => EX_data_memory_write_enable,
            EX_WB_z_register_write_enable    => EX_z_register_write_enable,
            EX_WB_z_register_reset           => EX_z_register_reset,
            EX_WB_alu_op_sel                 => EX_alu_op_sel,
            EX_WB_alu_op1_sel                => EX_alu_op1_sel,
            EX_WB_alu_op2_sel                => EX_alu_op2_sel,
            EX_WB_register_file_write_enable => EX_register_file_write_enable,
            EX_WB_pc_branch_conditional      => EX_pc_branch_conditional,
            EX_WB_pc_input_select            => EX_pc_input_select,
            EX_WB_j                          => EX_j,
            EX_WB_present                    => EX_present,
            EX_WB_data_memory_address        => EX_data_memory_address,
            EX_WB_data_memory_data_in        => EX_data_memory_data_in,
            EX_WB_data_memory_data_out       => EX_data_memory_data_out,
            EX_WB_dprr_clear                 => EX_dprr_clear,
            EX_WB_rz_index                   => EX_rz_index,
            EX_WB_rz                         => EX_rz,
            EX_WB_rx                         => EX_rx,
            EX_WB_immediate                  => EX_immediate,
            EX_WB_pc                         => EX_pc,
        );

    pipeline_reg_write_back : entity work.pipeline_reg_write_back
        port map(
            clock                             => clock,
            enable                            => enable,
            reset                             => reset,
            WB_register_file_write_enable     => EX_register_file_write_enable,
            WB_register_file_write_select     => EX_register_file_write_select,
            WB_rz_index                       => EX_rz_index,
            WB_alu_result                     => EX_alu_result,
            WB_data_memory_data_out           => EX_data_memory_data_out,
            WB_immediate                      => EX_immediate,
            WB_max                            => EX_max,
            WB_sip_data_out                   => EX_sip_data_out,

            WB_END_register_file_write_enable => WB_register_file_write_enable,
            WB_END_register_file_write_select => WB_register_file_write_select,
            WB_END_rz_index                   => WB_rz_index,
            WB_END_alu_result                 => WB_alu_result,
            WB_END_data_memory_data_out       => WB_data_memory_data_out,
            WB_END_immediate                  => WB_immediate,
            WB_END_max                        => WB_max,
            WB_END_sip_data_out               => WB_sip_data_out,
        );

    program_memory : entity work.prog_mem
        port map(
            address => program_memory_address,
            clock   => clock,
            q       => program_memory_data
        );

    data_memory_inst : entity work.data_memory
        port map(
            clock        => clock,
            reset        => reset,
            data_in      => data_memory_data_in,
            write_enable => data_memory_write_enable,
            address      => data_memory_address,
            data_out     => data_memory_data_out
        );

end architecture; -- top_level