library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.recop_types.all;
use work.opcodes;
use work.mux_select_constants.all;

entity top_level is
    port (
        clock             : in  std_logic;
        enable            : in  std_logic := '1';
        dprr              : in  std_logic_vector(31 downto 0);
        sip_data_in       : in  std_logic_vector(15 downto 0);
        reset             : in  std_logic := '0';
        dpcr_data_out     : out std_logic_vector(31 downto 0);
        sop_data_out      : out std_logic_vector(15 downto 0);
        state_decode_fail : out std_logic
    );
end entity;

architecture processor of top_level is

    signal dpcr_write_enable                  : std_logic := '0';
    signal dpcr_select                        : std_logic := '0';

    signal ssop                               : std_logic := '0';

    signal pc_write_enable                    : std_logic;
    signal jump_select                        : std_logic;
    signal register_file_write_select         : std_logic_vector(2 downto 0) := "000";
    signal register_file_rz_select            : std_logic;
    signal instruction_register_write_enable  : std_logic;
    signal alu_register_write_enable          : std_logic;

    signal data_memory_data_select            : std_logic_vector(1 downto 0);
    signal data_memory_address_select         : std_logic_vector(1 downto 0);
    signal data_memory_write_enable           : std_logic;

    signal data_memory_register_write_enable  : std_logic;
    signal z_register_write_enable            : std_logic;
    signal addressing_mode                    : std_logic_vector(1 downto 0);
    signal opcode                             : std_logic_vector(5 downto 0);
    signal z_register_reset                   : std_logic;

    signal alu_op_sel                         : std_logic_vector(1 downto 0);
    signal alu_op1_sel                        : std_logic_vector(1 downto 0);
    signal alu_op2_sel                        : std_logic_vector(1 downto 0);

    signal rz_register_write_enable           : std_logic;
    signal rx_register_write_enable           : std_logic;
    signal register_file_write_enable         : std_logic;

    signal pc_branch_conditional              : std_logic;
    signal pc_input_select                    : std_logic_vector(1 downto 0);

    signal program_memory_read_enable         : std_logic;
    signal program_memory_address             : std_logic_vector(15 downto 0);
    signal program_memory_data                : std_logic_vector(31 downto 0);

    signal data_memory_address                : std_logic_vector(15 downto 0);
    signal data_memory_data_in                : std_logic_vector(15 downto 0);
    signal data_memory_data_out               : std_logic_vector(15 downto 0);

    signal dprr_clear                         : std_logic;

    signal instruction_register_buffer_enable : std_logic;

    signal noclock                            : std_logic;

begin
    noclock <= not clock;

    data_path_inst : entity work.data_path
        port map(
            -- outputs
            addressing_mode                    => addressing_mode,
            opcode                             => opcode,

            -- inputs
            clock                              => clock,
            reset                              => reset,

            program_memory_address             => program_memory_address,
            program_memory_data                => program_memory_data,

            data_memory_address                => data_memory_address,
            data_memory_data_out               => data_memory_data_out,
            data_memory_data_in                => data_memory_data_in,

            pc_input_select                    => pc_input_select,
            pc_write_enable                    => pc_write_enable,
            pc_branch_conditional              => pc_branch_conditional,

            jump_select                        => jump_select,

            register_file_write_enable         => register_file_write_enable,
            register_file_write_select         => register_file_write_select,
            register_file_rz_select            => register_file_rz_select,

            instruction_register_write_enable  => instruction_register_write_enable,

            instruction_register_buffer_enable => instruction_register_buffer_enable,

            rz_register_write_enable           => rz_register_write_enable,
            rx_register_write_enable           => rx_register_write_enable,

            alu_register_write_enable          => alu_register_write_enable,
            alu_op1_sel                        => alu_op1_sel,
            alu_op2_sel                        => alu_op2_sel,
            alu_op_sel                         => alu_op_sel,

            data_memory_data_select            => data_memory_data_select,
            data_memory_address_select         => data_memory_address_select,

            data_memory_register_write_enable  => data_memory_register_write_enable,

            dpcr_enable                        => dpcr_write_enable,
            dpcr_data_out                      => dpcr_data_out,
            dpcr_data_select                   => dpcr_select,

            -- DPRR
            dprr_data_in                       => dprr,
            dprr_clear                         => dprr_clear,

            z_register_write_enable            => z_register_write_enable,
            z_register_reset                   => z_register_reset,

            ssop                               => ssop,
            sip_register_value_in              => sip_data_in,
            sop_register_value_out             => sop_data_out
        );

    control_uniinst : entity work.control_unit
        port map(
            clock                              => clock,
            enable                             => enable,
            reset                              => reset,
            addressing_mode                    => addressing_mode,
            opcode                             => opcode,

            dprr                               => dprr(1),
            dprr_clear                         => dprr_clear,
            jump_select                        => jump_select,
            dpcr_enable                        => dpcr_write_enable,
            dpcr_select                        => dpcr_select,

            alu_op_sel                         => alu_op_sel,
            alu_op1_sel                        => alu_op1_sel,
            alu_op2_sel                        => alu_op2_sel,
            alu_register_write_enable          => alu_register_write_enable,

            data_memory_address_select         => data_memory_address_select,
            data_memory_data_select            => data_memory_data_select,

            register_file_write_enable         => register_file_write_enable,
            register_file_write_select         => register_file_write_select,
            register_file_rz_select            => register_file_rz_select,

            rz_register_write_enable           => rz_register_write_enable,
            rx_register_write_enable           => rx_register_write_enable,

            z_register_write_enable            => z_register_write_enable,
            z_register_reset                   => z_register_reset,

            instruction_register_buffer_enable => instruction_register_buffer_enable,

            ssop_port                          => ssop,

            data_memory_write_enable           => data_memory_write_enable,
            data_memory_register_write_enable  => data_memory_register_write_enable,

            program_memory_read_enable         => program_memory_read_enable,
            instruction_register_write_enable  => instruction_register_write_enable,

            pc_write_enable                    => pc_write_enable,
            pc_branch_conditional              => pc_branch_conditional,
            pc_input_select                    => pc_input_select,

            state_decode_fail                  => state_decode_fail
        );

    program_memory : entity work.prog_mem
        port map(
            address => program_memory_address,
            clock   => clock,
            q       => program_memory_data
        );

    data_memory_inst : entity work.data_memory
        port map(
            clock        => noclock,
            reset        => reset,
            data_in      => data_memory_data_in,
            write_enable => data_memory_write_enable,
            address      => data_memory_address,
            data_out     => data_memory_data_out
        );

end architecture; -- top_level