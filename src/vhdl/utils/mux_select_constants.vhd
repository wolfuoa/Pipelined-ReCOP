library ieee;
use ieee.std_logic_1164.all;
use work.recop_types.all;

package mux_select_constants is
    -- PC
    constant pc_input_select_aluout             : std_logic_vector             := "00";
    constant pc_input_select_jmp                : std_logic_vector             := "01";
    constant pc_input_select_alu                : std_logic_vector             := "10"; -- Bypass the register

    -- Data Memory address
    constant data_memory_address_immediate      : std_logic_vector(1 downto 0) := "00";
    constant data_memory_address_rz             : std_logic_vector(1 downto 0) := "01";
    constant data_memory_address_rx             : std_logic_vector(1 downto 0) := "10";

    -- Data Memory data_in
    constant data_memory_data_immediate         : std_logic_vector(1 downto 0) := "00";
    constant data_memory_data_aluout            : std_logic_vector(1 downto 0) := "01";
    constant data_memory_data_rx                : std_logic_vector(1 downto 0) := "10";

    -- Instruction register write
    constant regfile_write_immediate            : std_logic_vector(2 downto 0) := "000";
    constant regfile_write_aluout               : std_logic_vector(2 downto 0) := "001";
    constant regfile_write_data_memory_register : std_logic_vector(2 downto 0) := "010";
    constant regfile_write_sip                  : std_logic_vector(2 downto 0) := "011";
    constant regfile_write_max                  : std_logic_vector(2 downto 0) := "100";

    -- Regfile Rz Select
    constant regfile_rz_normal                  : std_logic                    := '0';
    constant regfile_rz_r7                      : std_logic                    := '1';

    -- ALU
    -- OP1
    constant alu_op1_rz                         : std_logic_vector(1 downto 0) := "00";
    constant alu_op1_pc                         : std_logic_vector(1 downto 0) := "01";
    constant alu_op1_immediate                  : std_logic_vector(1 downto 0) := "10";

    -- OP2 
    constant alu_op2_rx                         : std_logic_vector(1 downto 0) := "00";
    constant alu_op2_zero                       : std_logic_vector(1 downto 0) := "01";
    constant alu_op2_one                        : std_logic_vector(1 downto 0) := "10";
    constant alu_op2_rz                         : std_logic_vector(1 downto 0) := "11";

    -- Jump 
    constant jump_immediate                     : std_logic                    := '0';
    constant jump_rx                            : std_logic                    := '1';

    -- DPCR 
    constant dpcr_rz                            : std_logic                    := '0';
    constant dpcr_immediate                     : std_logic                    := '1';

end package;