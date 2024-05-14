library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.recop_types.all;
use work.alu_ops;
use work.opcodes.all;
use work.mux_select_constants;

entity control_unit is
    port (
        clock                      : in  std_logic := '0';
        enable                     : in  std_logic := '0';
        reset                      : in  std_logic := '0';

        addressing_mode            : in  std_logic_vector(1 downto 0);
        opcode                     : in  std_logic_vector(5 downto 0);

        dprr                       : in  std_logic                    := '0';
        dprr_clear                 : out std_logic                    := '0';

        dpcr_enable                : out std_logic                    := '0';
        dpcr_select                : out std_logic                    := '0';

        data_memory_write_enable   : out std_logic                    := '0';
        data_memory_address_select : out std_logic_vector(1 downto 0) := "00";
        data_memory_data_select    : out std_logic_vector(1 downto 0) := "00";

        ssop_port                  : out std_logic                    := '0';

        register_file_write_select : out std_logic_vector(2 downto 0);
        register_file_write_enable : out std_logic := '0';
        register_file_rz_select    : out std_logic := '0';

        z_register_reset           : out std_logic := '0';
        z_register_write_enable    : out std_logic := '0';

        alu_op_sel                 : out std_logic_vector(1 downto 0);
        alu_op1_sel                : out std_logic;
        alu_op2_sel                : out std_logic_vector(1 downto 0);

        present                    : out std_logic := '0';

        jump_select                : out std_logic := '0';

        pc_branch_conditional      : out std_logic := '0';
        j                          : out std_logic := '0'

    );

end entity;

architecture rtl of control_unit is
    signal decoded_ALUop                  : std_logic_vector(1 downto 0);

    signal zor_dprr                       : std_logic                    := '0';
    signal zor_dprr_clear                 : std_logic                    := '0';
    signal zor_dpcr_enable                : std_logic                    := '0';
    signal zor_dpcr_select                : std_logic                    := '0';
    signal zor_data_memory_write_enable   : std_logic                    := '0';
    signal zor_data_memory_address_select : std_logic_vector(1 downto 0) := "00";
    signal zor_data_memory_data_select    : std_logic_vector(1 downto 0) := "00";
    signal zor_ssop_port                  : std_logic                    := '0';
    signal zor_register_file_write_select : std_logic_vector(2 downto 0) := "000";
    signal zor_register_file_write_enable : std_logic                    := '0';
    signal zor_register_file_rz_select    : std_logic                    := '0';
    signal zor_z_register_reset           : std_logic                    := '0';
    signal zor_z_register_write_enable    : std_logic                    := '0';
    signal zor_alu_op_sel                 : std_logic_vector(1 downto 0) := "00";
    signal zor_alu_op1_sel                : std_logic                    := '0';
    signal zor_alu_op2_sel                : std_logic_vector(1 downto 0) := "00";
    signal zor_present                    : std_logic                    := '0';
    signal zor_jump_select                : std_logic                    := '0';
    signal zor_pc_branch_conditional      : std_logic                    := '0';
    signal zor_j                          : std_logic                    := '0';

begin

    with opcode select
        decoded_ALUop <= alu_ops.alu_and when andr,
        alu_ops.alu_or when orr,
        alu_ops.alu_add when addr,
        alu_ops.alu_sub when subr,
        alu_ops.alu_sub when subvr,
        alu_ops.alu_add when others;

    ALU_OP_DECODE : process (opcode)
    begin
        case opcode is
            when andr =>
                decoded_ALUop <= alu_ops.alu_and;
            when orr =>
                decoded_ALUop <= alu_ops.alu_or;
            when addr =>
                decoded_ALUop <= alu_ops.alu_add;
            when subr =>
                decoded_ALUop <= alu_ops.alu_sub;
            when subvr =>
                decoded_ALUop <= alu_ops.alu_sub;
            when others =>
                decoded_ALUop <= "00";
        end case;

    end process;

    INSTRUCTION_DECODE : process (addressing_mode, opcode)
    begin

        zor_dprr                       <= '0';
        zor_dprr_clear                 <= '0';
        zor_dpcr_enable                <= '0';
        zor_dpcr_select                <= '0';
        zor_data_memory_write_enable   <= '0';
        zor_data_memory_address_select <= "00";
        zor_data_memory_data_select    <= "00";
        zor_ssop_port                  <= '0';
        zor_register_file_write_select <= "00";
        zor_register_file_write_enable <= '0';
        zor_register_file_rz_select    <= '0';
        zor_z_register_reset           <= '0';
        zor_z_register_write_enable    <= '0';
        zor_alu_op_sel                 <= decoded_ALUop;
        zor_alu_op1_sel                <= '0';
        zor_alu_op2_sel                <= "00";
        zor_present                    <= '0';
        zor_jump_select                <= '0';
        zor_pc_branch_conditional      <= '0';
        zor_j                          <= '0';

        case (addressing_mode) is
            when am_immediate => -- Immediate
                if (opcode = andr) then
                    zor_alu_op1_sel                <= '1';
                    -- zor_alu_op2_sel <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = orr) then
                    zor_alu_op1_sel                <= '1';
                    -- zor_alu_op2_sel <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = addr) then
                    zor_alu_op1_sel                <= '1';
                    -- zor_alu_op2_sel <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = subvr) then
                    zor_alu_op1_sel                <= '1';
                    -- zor_alu_op2_sel <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = subr) then
                    zor_alu_op1_sel                <= '1';
                    -- zor_alu_op2_sel <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = ldr) then
                    -- zor_register_file_write_select <= "00";
                    zor_register_file_write_enable <= '1';

                elsif (opcode = str) then
                    -- zor_data_memory_address_select <= "00";
                    zor_data_memory_data_select  <= "01";
                    zor_data_memory_write_enable <= '1';

                elsif (opcode = jmp) then
                    zor_j           <= '1';
                    zor_jump_select <= '1';

                elsif (opcode = present) then
                    zor_present     <= '1';
                    zor_jump_select <= '1';

                elsif (opcode = datacall) then
                    zor_dprr_clear  <= '1';
                    zor_dpcr_enable <= '1';
                    zor_dpcr_select <= '1';

                elsif (opcode = sz) then
                    zor_branch_conditional <= '1';
                    zor_jump_select        <= '1';
                    -- zor_present <= '0';

                elsif (opcode = max) then
                    zor_register_file_write_select <= "100";
                    zor_register_file_write_enable <= '1';

                end if;

            when am_register => -- Register
                if (opcode = andr) then
                    -- zor_alu_op1_sel                <= '0';
                    -- zor_alu_op2_sel                <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = orr) then
                    -- zor_alu_op1_sel                <= '0';
                    -- zor_alu_op2_sel                <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = addr) then
                    -- zor_alu_op1_sel                <= '0';
                    -- zor_alu_op2_sel                <= '0';
                    zor_register_file_write_select <= "001";
                    zor_z_register_write_enable    <= '1';
                    zor_register_file_write_enable <= '1';

                elsif (opcode = ldr) then
                    zor_data_memory_address_select <= "10";
                    zor_register_file_write_select <= "010";
                    zor_register_file_write_enable <= '1';

                elsif (opcode = str) then
                    -- zor_data_memory_address_select <= "00";
                    zor_data_memory_data_select  <= "10";
                    zor_data_memory_write_enable <= '1';

                elsif (opcode = jmp) then
                    zor_j <= '1';
                    -- zor_jump_select <= '0';

                elsif (opcode = datacall) then
                    zor_register_file_rz_select <= '1';
                    zor_dprr_clear              <= '1';
                    zor_dpcr_enable             <= '1';
                    -- zor_dpcr_select <= '0';

                elsif (opcode = lsip) then
                    zor_register_file_write_select <= "011";
                    zor_register_file_write_enable <= '1';

                elsif (opcode = ssop) then
                    zor_ssop_port <= '1';

                end if;

            when am_direct =>
                if (opcode = ldr) then
                    zor_data_memory_address_select <= "01";
                    zor_register_file_write_select <= "010";
                    zor_register_file_write_enable <= '1';

                elsif (opcode = str) then
                    zor_data_memory_address_select <= "01";
                    -- zor_data_memory_data_select    <= "00";
                    zor_data_memory_write_enable   <= '1';

                elsif (opcode = strpc) then
                    zor_data_memory_address_select <= "01";
                    zor_data_memory_data_select    <= "10";
                    zor_data_memory_write_enable   <= '1';

                end if;

            when others => -- Inherent
                if (opcode = clfz) then
                    zor_z_register_reset <= '1';
                    -- zor_z_register_write_enable    <= '0';

                elsif (opcode = noop)
                end if;
        end case;

        dprr                       <= zor_dprr;
        dprr_clear                 <= zor_dprr_clear;
        dpcr_enable                <= zor_dpcr_enable;
        dpcr_select                <= zor_dpcr_select;
        data_memory_write_enable   <= zor_data_memory_write_enable;
        data_memory_address_select <= zor_data_memory_write_select;
        data_memory_data_select    <= zor_data_memory_data_select;
        ssop_port                  <= zor_ssop_port;
        register_file_write_select <= zor_register_file_write_select;
        register_file_write_enable <= zor_register_file_write_enable;
        register_file_rz_select    <= zor_register_file_rz_select;
        z_register_reset           <= zor_z_register_reset;
        z_register_write_enable    <= zor_z_register_write_enable;
        alu_op_sel                 <= zor_alu_op_sel;
        alu_op1_sel                <= zor_alu_op1_sel;
        alu_op2_sel                <= zor_alu_op2_sel;
        present                    <= zor_present;
        jump_select                <= zor_jump_select;
        pc_branch_conditional      <= zor_pc_branch_conditional;
        j                          <= zor_j;

    end process;

end architecture;