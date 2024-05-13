library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.recop_types.all;
use work.opcodes;
use work.mux_select_constants.all;

entity testbench_top_level is
    port (
        t_zero_reg_reset    : out std_logic;
        t_state_decode_fail : out std_logic
    );
end entity;

architecture test of testbench_top_level is
    signal t_clock                              : std_logic := '0';
    signal t_enable                             : std_logic := '1';
    signal t_reset                              : std_logic := '0';
    signal t_dprr                               : std_logic_vector(31 downto 0);

    signal t_dpcr_write_enable                  : std_logic := '0';
    signal t_dpcr_select                        : std_logic := '0';

    signal t_ssop                               : std_logic := '0';

    signal t_pc_write_enable                    : std_logic;
    signal t_jump_select                        : std_logic;
    signal t_register_file_write_select         : std_logic_vector(2 downto 0) := "000";
    signal t_register_file_rz_select            : std_logic;
    signal t_instruction_register_write_enable  : std_logic;
    signal t_alu_register_write_enable          : std_logic;

    signal t_data_memory_data_select            : std_logic_vector(1 downto 0);
    signal t_data_memory_address_select         : std_logic_vector(1 downto 0);
    signal t_data_memory_write_enable           : std_logic;

    signal t_data_memory_register_write_enable  : std_logic;
    signal t_z_register_write_enable            : std_logic;
    signal t_addressing_mode                    : std_logic_vector(1 downto 0);
    signal t_opcode                             : std_logic_vector(5 downto 0);
    signal t_z_register_reset                   : std_logic;

    signal t_alu_op_sel                         : std_logic_vector(1 downto 0);
    signal t_alu_op1_sel                        : std_logic_vector(1 downto 0);
    signal t_alu_op2_sel                        : std_logic_vector(1 downto 0);

    signal t_rz_register_write_enable           : std_logic;
    signal t_rx_register_write_enable           : std_logic;
    signal t_register_file_write_enable         : std_logic;

    signal t_sip_value                          : std_logic_vector(15 downto 0);
    signal t_sop_register_value_out             : std_logic_vector(15 downto 0);

    signal t_pc_branch_conditional              : std_logic;
    signal t_pc_input_select                    : std_logic_vector(1 downto 0);

    signal t_program_memory_read_enable         : std_logic;
    signal t_program_memory_address             : std_logic_vector(15 downto 0);
    signal t_program_memory_data                : std_logic_vector(31 downto 0);

    signal t_data_memory_address                : std_logic_vector(15 downto 0);
    signal t_data_memory_data_in                : std_logic_vector(15 downto 0);
    signal t_data_memory_data_out               : std_logic_vector(15 downto 0);

    signal t_dpcr_data_out                      : std_logic_vector(31 downto 0);
    signal t_dprr_clear                         : std_logic;

    signal t_instruction_register_buffer_enable : std_logic;

    signal not_t_clock                          : std_logic;

    type memory_array is array (0 to 76) of std_logic_vector(31 downto 0);
    signal progam_memory_inst : memory_array := (
        -- AM(2) Opcode(6) Rz(4) Rx(4) Operand(16) and register - register 
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"1fff",   -- Load 1 0x1fff into Reg(1)
        opcodes.am_register & opcodes.andr & "0001" & "0000" & x"EEEE",   -- And Reg(1) which is 0x1fff with Reg(0) which is 0
        -- And immediate
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"1fff",   -- Load 1 0x1fff into Reg(1)
        opcodes.am_immediate & opcodes.andr & "0000" & "0001" & x"1fff",  -- 0x1fff and 0x1fff
        -- Or immediate
        opcodes.am_immediate & opcodes.orr & "0010" & "0010" & x"FF00",   -- OR x0000 with xFF00 to Reg(2)
        -- Or regiter-register
        opcodes.am_immediate & opcodes.orr & "0011" & "0011" & x"00FF",   -- OR Reg(3) with x00FF
        opcodes.am_register & opcodes.orr & "0010" & "0011" & x"EEEE",    -- OR Reg(2) with Reg(3) - Output 0xFFFF into Reg(2)
        -- Add Immediate
        opcodes.am_immediate & opcodes.ldr & "0100" & "0000" & x"0001",   -- Load 1 into Reg(4)
        opcodes.am_immediate & opcodes.addr & "0100" & "0100" & x"4444",  -- Add x4444 to Reg(4)
        -- Add register-register
        opcodes.am_immediate & opcodes.ldr & "0101" & "0000" & x"6969",   -- Load 1 0x6969 into Reg(5)
        opcodes.am_register & opcodes.addr & "0101" & "0101" & x"EEEE",   -- 0x6969 + 0x6969
        -- SUBV immediate
        opcodes.am_immediate & opcodes.ldr & "0110" & "0000" & x"B00B",   -- Load 1 0xB00B into Reg(6)
        opcodes.am_immediate & opcodes.subvr & "0000" & "0110" & x"B00B", -- Should be 0
        -- SUB
        opcodes.am_immediate & opcodes.ldr & "0111" & "0000" & x"0001",   -- $r7 <= x0001 
        opcodes.am_immediate & opcodes.subr & "0111" & "0000" & x"0001",  -- 1 - 1 should assert Z register as 1, $r7 stays at 1
        -- Test Store IMM
        opcodes.am_immediate & opcodes.ldr & "0011" & "0000" & x"0001",   -- Load 1 0x0001 into Reg(3)
        opcodes.am_immediate & opcodes.str & "0011" & "0000" & x"6969",   -- Store 0x6969 into address 0x0001
        -- Test Load $Rg
        opcodes.am_register & opcodes.ldr & "0100" & "0011" & x"EEEE",    -- Load content of memory at address Reg 3 into Reg(4) -> Reg(4) = 0x6969
        opcodes.am_immediate & opcodes.ldr & "0101" & "0000" & x"00E1",
        -- Test Store Reg at Reg
        opcodes.am_immediate & opcodes.ldr & "1000" & "0000" & x"BEEF", -- Load 0xBEEF into register (8) Rx - BEEF
        opcodes.am_immediate & opcodes.ldr & "1001" & "0000" & x"0003", -- Load 0x0003 into register (9) Rz - 3

        opcodes.am_register & opcodes.str & "1001" & "1000" & x"EEEE",  -- Store contents of Rx into address Rz - DM[x0003] = 0xBEEF
        opcodes.am_register & opcodes.ldr & "1010" & "1001" & x"EEEE",  -- Rz(1010) <= DM[x0003] 

        -- Test store Reg at Immediate
        opcodes.am_immediate & opcodes.ldr & "1000" & "0000" & x"D1CC", -- Load 0xD1CC into register (8) Rx - D1CC
        opcodes.am_direct & opcodes.str & "0000" & "1000" & x"0004",    -- DM[x0004] <= Rx

        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0004", -- Store 4 into $r0
        opcodes.am_register & opcodes.ldr & "1010" & "0000" & x"EEEE",  -- Rz(1010) <= DM[x0004] 

        -- Test load direct (Rz <= DM[Imm])
        opcodes.am_immediate & opcodes.ldr & "1100" & "0000" & x"C0CC", -- Load 0xD1CC into register (12) Rx - C0CC
        opcodes.am_direct & opcodes.str & "0000" & "1100" & x"0005",    -- DM[x0005] <= Rx
        opcodes.am_direct & opcodes.ldr & "1101" & "0000" & x"0005",    -- $13 <= DM[x0005] (i.e $13 <= 0xC0CC)

        -- Test Jump immediate instruction
        opcodes.am_immediate & opcodes.jmp & "0000" & "0000" & x"0020", -- Skip past instruction 32 to 33
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"EEEE", -- Dummy instruction that should be skipped
        opcodes.am_immediate & opcodes.ldr & "1010" & "0000" & x"CAFE", -- Store 0x24 (36) into $r0

        -- Test Jump Register
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0024", -- Store 0x25 (37) into $r0
        opcodes.am_register & opcodes.jmp & "0000" & "0000" & x"EEEE",  -- Jump to 37 (which is stored in $r0)
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0E0F", -- Dummy instruction that should be skipped
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"B00B", -- (36) Should jump to this

        -- Test Present VALID
        opcodes.am_immediate & opcodes.ldr & "0011" & "0000" & x"0000", -- Load x0000 into $r3
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"EEEE", -- Load ERROR into $r0 to ensure correct reg is checked for 0 by ALU
        opcodes.am_immediate & opcodes.present & "0011" & "0000" & x"0029",
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"ABCD",                 -- Dummy instruction that should be skipped
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"DCBA",                 -- Instruction to resume (41)

        -- Test Present FALSE
        opcodes.am_immediate & opcodes.ldr & "0111" & "0000" & x"0024",                 -- Store 0x25 (37) into $r6
        opcodes.am_immediate & opcodes.present & "0111" & "0000" & x"002D",             -- Jump to 45 if rz is 0 (never true)
        opcodes.am_immediate & opcodes.ldr & "0011" & "0000" & x"D1CC",                 -- Should run
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"D1CC",                 -- Should run

        -- Test DATACALL Reg
        opcodes.am_immediate & opcodes.ldr & "0111" & "0000" & x"5678",                 -- Load 0x5678 into $r7
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"1234",                 -- Load 0x1234 into $r1
        opcodes.am_register & opcodes.datacall_reg_opcode & "0000" & "0001" & x"EEEE",  -- Should put x12345678 into DPRR and wait
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0420",                 -- Execute this instruction when unblocked

        -- Test DATACALL Imm
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"89AB",                 -- Load 0x1234 into $r1
        opcodes.am_immediate & opcodes.datacall_imm_opcode & "0000" & "0001" & x"CDEF", -- Should put x89ABCDEF into DPRR and wait
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0421",                 -- Execute this instruction when unblocked

        -- Test No-Op
        opcodes.am_immediate & opcodes.noop & "0000" & "0000" & x"EEEE",                -- No operation done (53)

        -- Test Sizzm True (Jump if Z register is 1)
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"4204",                 -- Load 0x1234 into $r1
        opcodes.am_immediate & opcodes.subvr & "0000" & "0001" & x"4204",               -- Perform sub that should give 0
        opcodes.am_register & opcodes.sz & "0000" & "0001" & x"003B",                   -- jump to 59
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"EEEE",                 -- Needs to be skipped because conditional was true
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"EEEE",                 -- Needs to be skipped because conditional was true
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"900D",                 -- Should jump to here (59)

        -- Test Sizzm False (Jump if Z register is 1)
        opcodes.am_immediate & opcodes.ldr & "0001" & "0000" & x"1000",                 -- Load 0x1234 into $r1
        opcodes.am_immediate & opcodes.subvr & "0010" & "0001" & x"0500",               -- Subtract x500 from x1000, srore result in $r2
        opcodes.am_register & opcodes.sz & "0000" & "0001" & x"0040",                   -- Should not take the jump
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"CCCC",                 -- Should not be skipped
        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"CCCD",                 -- Should not be skipped    (0040)

        -- Test strpc
        opcodes.am_immediate & opcodes.strpc & "0000" & "0000" & x"0008",               -- DM[x0008] <= PC + 1
        opcodes.am_direct & opcodes.ldr & "1111" & "0000" & x"0008",                    -- $r15 <= DM[x0008] = 65 (x42)

        -- Test Clear Z
        opcodes.am_immediate & opcodes.ldr & "0111" & "0000" & x"0001",                 -- $r7 <= x0001 
        opcodes.am_immediate & opcodes.subr & "0111" & "0000" & x"0001",                -- 1 - 1 should assert Z register as 1, $r7 stays at 1
        opcodes.am_inherent & opcodes.clfz & "1111" & "1111" & x"EEEE",                 -- 1 - 1 should assert Z register as 1, $r7 stays at 1

        -- Test ssop
        opcodes.am_immediate & opcodes.ldr & "1101" & "0000" & x"F00D",                 -- $r13 <= xF00D c
        opcodes.am_register & opcodes.ssop & "0000" & "1101" & x"EEEE",                 -- Load xF00D into SOP register

        -- Test lsip
        opcodes.am_register & opcodes.lsip & "1110" & "0000" & x"EEEE",                 -- Load sip into $14

        -- Test Max
        opcodes.am_immediate & opcodes.ldr & "0100" & "0000" & x"1000",                 -- $r4 <= x1000 c
        opcodes.am_immediate & opcodes.max & "0100" & "0000" & x"0900",                 -- $r4 remains x1000
        opcodes.am_immediate & opcodes.max & "0100" & "0000" & x"1001",                 -- $r4 changes to x1001

        --------------------------------------------END OF FILE--------------------------------------------

        opcodes.am_immediate & opcodes.ldr & "0000" & "0000" & x"0E0F"                  -- Buffer instruction to ensure the last instruction is completed (PC increment)
    );

    signal program_memory_data    : std_logic_vector(31 downto 0);
    signal program_memory_address : std_logic_vector(15 downto 0);

begin
    program_memory_data <= progam_memory_inst(to_integer(unsigned(program_memory_address)));
    not_t_clock         <= not t_clock;

    data_path_inst : entity work.data_path
        port map(
            -- outputs
            addressing_mode                    => t_addressing_mode,
            opcode                             => t_opcode,

            -- inputs
            clock                              => t_clock,
            reset                              => t_reset,

            program_memory_address             => program_memory_address,
            program_memory_data                => program_memory_data,

            data_memory_address                => t_data_memory_address,
            data_memory_data_out               => t_data_memory_data_out,
            data_memory_data_in                => t_data_memory_data_in,

            pc_input_select                    => t_pc_input_select,
            pc_write_enable                    => t_pc_write_enable,
            pc_branch_conditional              => t_pc_branch_conditional,

            jump_select                        => t_jump_select,

            register_file_write_enable         => t_register_file_write_enable,
            register_file_write_select         => t_register_file_write_select,
            register_file_rz_select            => t_register_file_rz_select,

            instruction_register_write_enable  => t_instruction_register_write_enable,

            instruction_register_buffer_enable => t_instruction_register_buffer_enable,

            rz_register_write_enable           => t_rz_register_write_enable,
            rx_register_write_enable           => t_rx_register_write_enable,

            alu_register_write_enable          => t_alu_register_write_enable,
            alu_op1_sel                        => t_alu_op1_sel,
            alu_op2_sel                        => t_alu_op2_sel,
            alu_op_sel                         => t_alu_op_sel,

            data_memory_data_select            => t_data_memory_data_select,
            data_memory_address_select         => t_data_memory_address_select,

            data_memory_register_write_enable  => t_data_memory_register_write_enable,

            dpcr_enable                        => t_dpcr_write_enable,
            dpcr_data_out                      => t_dpcr_data_out,
            dpcr_data_select                   => t_dpcr_select,

            -- DPRR
            dprr_data_in                       => t_dprr,
            dprr_clear                         => t_dprr_clear,

            z_register_write_enable            => t_z_register_write_enable,
            z_register_reset                   => t_z_register_reset,

            ssop                               => t_ssop,
            sip_register_value_in              => t_sip_value,
            sop_register_value_out             => t_sop_register_value_out
        );

    control_unit_inst : entity work.control_unit
        port map(
            clock                              => t_clock,
            enable                             => t_enable,
            reset                              => t_reset,
            addressing_mode                    => t_addressing_mode,
            opcode                             => t_opcode,

            dprr                               => t_dprr(1),
            dprr_clear                         => t_dprr_clear,
            jump_select                        => t_jump_select,
            dpcr_enable                        => t_dpcr_write_enable,
            dpcr_select                        => t_dpcr_select,

            alu_op_sel                         => t_alu_op_sel,
            alu_op1_sel                        => t_alu_op1_sel,
            alu_op2_sel                        => t_alu_op2_sel,
            alu_register_write_enable          => t_alu_register_write_enable,

            data_memory_address_select         => t_data_memory_address_select,
            data_memory_data_select            => t_data_memory_data_select,

            register_file_write_enable         => t_register_file_write_enable,
            register_file_write_select         => t_register_file_write_select,
            register_file_rz_select            => t_register_file_rz_select,

            rz_register_write_enable           => t_rz_register_write_enable,
            rx_register_write_enable           => t_rx_register_write_enable,

            z_register_write_enable            => t_z_register_write_enable,
            z_register_reset                   => t_zero_reg_reset,

            instruction_register_buffer_enable => t_instruction_register_buffer_enable,

            ssop_port                          => t_ssop,

            data_memory_write_enable           => t_data_memory_write_enable,
            data_memory_register_write_enable  => t_data_memory_register_write_enable,

            program_memory_read_enable         => t_program_memory_read_enable,
            instruction_register_write_enable  => t_instruction_register_write_enable,

            pc_write_enable                    => t_pc_write_enable,
            pc_branch_conditional              => t_pc_branch_conditional,
            pc_input_select                    => t_pc_input_select,

            state_decode_fail                  => t_state_decode_fail
        );

    data_memory_inst : entity work.data_memory
        port map(
            clock        => not_t_clock,
            reset        => t_reset,
            data_in      => t_data_memory_data_in,
            write_enable => t_data_memory_write_enable,
            address      => t_data_memory_address,
            data_out     => t_data_memory_data_out
        );

    -- Clock
    process
    begin
        wait for 10 ns;
        t_clock <= '0';
        wait for 10 ns;
        t_clock <= '1';
    end process;

    process
    begin
        wait for 2800 ns;
        t_dprr(1) <= '1';
        wait for 20 ns;
        t_dprr(1) <= '0';
        wait for 300 ns;
        t_dprr(1) <= '1';
    end process;

    process
    begin
        wait for 2800 ns;
        t_sip_value <= x"F0CC";
        wait;
    end process;
end architecture;