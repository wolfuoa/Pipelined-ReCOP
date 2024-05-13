library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.recop_types.all;
use work.opcodes.all;
use work.mux_select_constants.all;
use work.alu_ops.all;

entity alu is
    port (
        zero          : out std_logic;

        -- ALU operation selection
        alu_operation : in  std_logic_vector(1 downto 0);

        -- operand selection
        alu_op1_sel   : in  std_logic_vector(1 downto 0);
        alu_op2_sel   : in  std_logic_vector(1 downto 0);

        -- External OP1 MUX inputs
        rz            : in  std_logic_vector(15 downto 0);
        immediate     : in  std_logic_vector(15 downto 0);
        pc            : in  std_logic_vector(15 downto 0);

        -- External OP2 MUX inputs
        rx            : in  std_logic_vector(15 downto 0);

        -- flag control signal
        alu_result    : out std_logic_vector(15 downto 0) := X"0000"
    );
end entity;

architecture combined of alu is
    signal operand_1 : std_logic_vector(15 downto 0);
    signal operand_2 : std_logic_vector(15 downto 0);
    signal result    : std_logic_vector(15 downto 0);
begin

    --MUX selecting first operand
    with alu_op1_sel select operand_1
        <=
        rz when alu_op1_rz,
        pc when alu_op1_pc,
        immediate when alu_op1_immediate,
        x"0000" when others;

    --MUX selecting second operand
    with alu_op2_sel select operand_2
        <=
        rx when alu_op2_rx,
        x"0000" when alu_op2_zero,
        x"0001" when alu_op2_one,
        rz when alu_op2_rz,
        x"0000" when others;

    zero <= '1' when result = x"0000" else
            '0';

    -- perform ALU operation
    alu : process (alu_operation, operand_1, operand_2)
    begin
        case alu_operation is
            when alu_add =>
                result <= operand_2 + operand_1;
            when alu_sub =>
                result <= operand_2 - operand_1;
            when alu_and =>
                result <= operand_2 and operand_1;
            when alu_or =>
                result <= operand_2 or operand_1;
            when others =>
                result <= X"0000";
        end case;
    end process;

    alu_result <= result;

end architecture;