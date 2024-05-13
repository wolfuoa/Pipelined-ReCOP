library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.recop_types;
use work.opcodes;
use work.mux_select_constants;

entity data_path is
    port (
        clock                              : in  std_logic;
        reset                              : in  std_logic;

        -- Program memory interface
        program_memory_address             : out std_logic_vector(15 downto 0);
        program_memory_data                : in  std_logic_vector(31 downto 0);

        -- Data memory interface
        data_memory_address                : out std_logic_vector(15 downto 0);
        data_memory_data_out               : in  std_logic_vector(15 downto 0);
        data_memory_data_in                : out std_logic_vector(15 downto 0);

        -- Control unit inputs
        pc_input_select                    : in  std_logic_vector(1 downto 0);
        pc_write_enable                    : in  std_logic;
        pc_branch_conditional              : in  std_logic;

        jump_select                        : in  std_logic;

        register_file_write_enable         : in  std_logic;
        register_file_write_select         : in  std_logic_vector(2 downto 0);
        register_file_rz_select            : in  std_logic;

        instruction_register_write_enable  : in  std_logic;
        rz_register_write_enable           : in  std_logic;
        rx_register_write_enable           : in  std_logic;

        -- ALU
        alu_register_write_enable          : in  std_logic;
        alu_op1_sel                        : in  std_logic_vector(1 downto 0);
        alu_op2_sel                        : in  std_logic_vector(1 downto 0);
        alu_op_sel                         : in  std_logic_vector(1 downto 0);

        -- Data Memory
        data_memory_data_select            : in  std_logic_vector(1 downto 0);
        data_memory_address_select         : in  std_logic_vector(1 downto 0);

        data_memory_register_write_enable  : in  std_logic;

        -- DPCR
        dpcr_enable                        : in  std_logic;
        dpcr_data_select                   : in  std_logic;
        dpcr_data_out                      : out std_logic_vector(31 downto 0);

        -- DPRR
        dprr_data_in                       : in  std_logic_vector(31 downto 0);

        dprr_clear                         : in  std_logic;

        z_register_write_enable            : in  std_logic;
        z_register_reset                   : in  std_logic;

        -- IR Register Buffer Enable
        instruction_register_buffer_enable : in  std_logic;
        --END Control unit inputs
        -- SIP and SOP Control Signals``
        ssop                               : in  std_logic;

        -- External I/O
        sip_register_value_in              : in  std_logic_vector(15 downto 0);
        sop_register_value_out             : out std_logic_vector(15 downto 0);

        -- Outputs for the control unit
        addressing_mode                    : out std_logic_vector(1 downto 0);
        opcode                             : out std_logic_vector(5 downto 0)
    );
end entity;

architecture bhv of data_path is
    signal jump_address                         : std_logic_vector(15 downto 0);

    signal pc                                   : std_logic_vector(15 downto 0);
    signal pc_write                             : std_logic;

    signal instruction                          : std_logic_vector(31 downto 0);
    signal rx_index                             : std_logic_vector(3 downto 0);
    signal rz_index                             : std_logic_vector(3 downto 0);
    signal immediate                            : std_logic_vector(15 downto 0);

    signal immediate_buffer_register_value_out  : std_logic_vector(15 downto 0);

    signal rz_address_buffer_register_value_out : std_logic_vector(3 downto 0);

    signal rz_register_value_in                 : std_logic_vector(15 downto 0);
    signal rx_register_value_in                 : std_logic_vector(15 downto 0);

    signal rz_register_value_out                : std_logic_vector(15 downto 0);
    signal rx_register_value_out                : std_logic_vector(15 downto 0);

    signal alu_register_value_in                : std_logic_vector(15 downto 0);
    signal alu_register_value_out               : std_logic_vector(15 downto 0);

    signal sip_register_value_out               : std_logic_vector(15 downto 0);

    signal data_memory_register_data_in         : std_logic_vector(15 downto 0);
    signal data_memory_register_data_out        : std_logic_vector(15 downto 0);

    signal z_register_value_in                  : std_logic_vector(0 downto 0);
    signal z_register_value_out                 : std_logic_vector(0 downto 0);

    signal dprr_data_out                        : std_logic_vector(31 downto 0);

    signal dpcr_data_in                         : std_logic_vector(31 downto 0);

    signal dprr_register_data_in                : std_logic_vector(31 downto 0);

    signal max_result                           : std_logic_vector(15 downto 0);

    signal not_clock                            : std_logic;

begin

    not_clock                            <= not clock;

    -- Calculate jump address
    with jump_select select jump_address <=
                                           rx_register_value_out when '1',
                                           immediate when others;

    pc_write <= (z_register_value_out(0) and pc_branch_conditional) or pc_write_enable;

    instruction_register_inst : entity work.instruction_register
        port map(
            clock           => not_clock,
            reset           => reset,
            write_enable    => instruction_register_write_enable,
            instruction     => instruction,
            addressing_mode => addressing_mode,
            opcode          => opcode,
            rz              => rz_index,
            rx              => rx_index,
            immediate       => immediate
        );

    -- IR Buffers
    rz_address_buffer : entity work.register_buffer
        generic map(
            width => 4
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => instruction_register_buffer_enable,
            data_in      => rz_index,
            data_out     => rz_address_buffer_register_value_out
        );

    immediate_buffer : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => instruction_register_buffer_enable,
            data_in      => immediate,
            data_out     => immediate_buffer_register_value_out
        );

    pc_inst : entity work.pc
        generic map(
            START_ADDR => (others => '0')
        )
        port map(
            clock           => clock,
            reset           => reset,
            write_enable    => pc_write, -- Needs to be different from the input port one
            pc_input_select => pc_input_select,
            jump_address    => jump_address,
            alu_out         => alu_register_value_out,
            alu             => alu_register_value_in,
            pc              => pc
        );

    -- Register file
    register_file : entity work.register_file
        port map(
            clock                 => clock,
            reset                 => reset,
            write_enable          => register_file_write_enable,
            rz_index              => rz_address_buffer_register_value_out,
            rx_index              => rx_index,
            rz_select             => register_file_rz_select,
            register_write_select => register_file_write_select,
            immediate             => immediate_buffer_register_value_out,
            data_memory           => data_memory_register_data_out,
            alu_out               => alu_register_value_out,
            sip                   => sip_register_value_out,
            max_result            => max_result,
            rx                    => rx_register_value_in,
            rz                    => rz_register_value_in
        );
    -- Operand Registers
    rx_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => rx_register_write_enable,
            data_in      => rx_register_value_in,
            data_out     => rx_register_value_out
        );

    rz_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => rz_register_write_enable,
            data_in      => rz_register_value_in,
            data_out     => rz_register_value_out
        );

    -- ALU
    alu : entity work.alu
        port map(
            alu_operation => alu_op_sel,

            -- mux selects
            alu_op1_sel   => alu_op1_sel,
            alu_op2_sel   => alu_op2_sel,

            -- mux inputs
            immediate     => immediate,
            pc            => pc,
            rz            => rz_register_value_out,
            rx            => rx_register_value_out,

            -- outputs
            zero          => z_register_value_in(0),
            alu_result    => alu_register_value_in
        );

    -- ALU Reg
    alu_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => alu_register_write_enable,
            data_in      => alu_register_value_in,
            data_out     => alu_register_value_out
        );

    -- Data Memory Register
    data_memory_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => data_memory_register_write_enable,
            data_in      => data_memory_register_data_in,
            data_out     => data_memory_register_data_out
        );

    -- Zero register
    z_register : entity work.register_buffer
        generic map(
            width => 1
        )
        port map(
            clock        => clock,
            reset        => z_register_reset,
            write_enable => z_register_write_enable,
            data_in      => z_register_value_in,
            data_out     => z_register_value_out
        );

    -- SIP
    sip_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => '1',
            data_in      => sip_register_value_in,
            data_out     => sip_register_value_out
        );

    sop_register : entity work.register_buffer
        generic map(
            width => 16
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => ssop,
            data_in      => rx_register_value_out,
            data_out     => sop_register_value_out
        );
    dprr : entity work.register_buffer
        generic map(
            width => 32
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => '1',
            data_in      => dprr_register_data_in,
            data_out     => dprr_data_out
        );

    dpcr : entity work.register_buffer
        generic map(
            width => 32
        )
        port map(
            clock        => clock,
            reset        => reset,
            write_enable => dpcr_enable,
            data_in      => dpcr_data_in,
            data_out     => dpcr_data_out
        );

    zoranmaxx : entity work.max
        port map(
            op1    => rz_register_value_out,
            op2    => immediate_buffer_register_value_out,
            result => max_result
        );

    with dpcr_data_select select dpcr_data_in
        <= rx_register_value_out & rz_register_value_out when mux_select_constants.dpcr_rz,
        rx_register_value_out & immediate_buffer_register_value_out when others;

    dprr_register_data_in <= dprr_data_in when (dprr_clear = '0') else
                             (dprr_data_in and x"FFFD");

    with data_memory_data_select select
        data_memory_data_in <= immediate when mux_select_constants.data_memory_data_immediate,
        alu_register_value_out when mux_select_constants.data_memory_data_aluout,
        rx_register_value_out when mux_select_constants.data_memory_data_rx,
        x"0000" when others;

    with data_memory_address_select select
        data_memory_address <= immediate when mux_select_constants.data_memory_address_immediate,
        rx_register_value_out when mux_select_constants.data_memory_address_rx,
        rz_register_value_out when mux_select_constants.data_memory_address_rz,
        x"0000" when others;

    program_memory_address       <= pc;
    instruction                  <= program_memory_data;
    data_memory_register_data_in <= data_memory_data_out;

end architecture;