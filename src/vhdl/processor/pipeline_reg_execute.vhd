entity pipeline_reg_execute is
    port (
        clock                            : in  std_logic;
        enable                           : in  std_logic;
        reset                            : in  std_logic;

        EX_dpcr_write_enable             : in  std_logic;
        EX_dpcr_select                   : in  std_logic;
        EX_ssop                          : in  std_logic;
        EX_jump_select                   : in  std_logic;
        EX_register_file_write_select    : in  std_logic_vector(2 downto 0);
        EX_data_memory_data_select       : in  std_logic_vector(1 downto 0);
        EX_data_memory_address_select    : in  std_logic_vector(1 downto 0);
        EX_data_memory_write_enable      : in  std_logic;
        EX_z_register_write_enable       : in  std_logic;
        EX_z_register_reset              : in  std_logic;
        EX_alu_op_sel                    : in  std_logic_vector(1 downto 0);
        EX_alu_op1_sel                   : in  std_logic_vector(1 downto 0);
        EX_alu_op2_sel                   : in  std_logic_vector(1 downto 0);
        EX_register_file_write_enable    : in  std_logic;
        EX_pc_branch_conditional         : in  std_logic;
        EX_pc_input_select               : in  std_logic_vector(1 downto 0);
        EX_j                             : in  std_logic;
        EX_present                       : in  std_logic;
        EX_data_memory_address           : in  std_logic_vector(15 downto 0);
        EX_data_memory_data_in           : in  std_logic_vector(15 downto 0);
        EX_data_memory_data_out          : in  std_logic_vector(15 downto 0);
        EX_dprr_clear                    : in  std_logic;
        EX_rz_index                      : in  std_logic_vector(3 downto 0);
        EX_rz                            : in  std_logic_vector(15 downto 0);
        EX_rx                            : in  std_logic_vector(15 downto 0);
        EX_immediate                     : in  std_logic_vector(15 downto 0);
        EX_pc                            : in  std_logic_vector(15 downto 0);

        EX_WB_dpcr_write_enable          : out std_logic;
        EX_WB_dpcr_select                : out std_logic;
        EX_WB_ssop                       : out std_logic;
        EX_WB_jump_select                : out std_logic;
        EX_WB_register_file_write_select : out std_logic_vector(2 downto 0);
        EX_WB_data_memory_data_select    : out std_logic_vector(1 downto 0);
        EX_WB_data_memory_address_select : out std_logic_vector(1 downto 0);
        EX_WB_data_memory_write_enable   : out std_logic;
        EX_WB_z_register_write_enable    : out std_logic;
        EX_WB_z_register_reset           : out std_logic;
        EX_WB_alu_op_sel                 : out std_logic_vector(1 downto 0);
        EX_WB_alu_op1_sel                : out std_logic_vector(1 downto 0);
        EX_WB_alu_op2_sel                : out std_logic_vector(1 downto 0);
        EX_WB_register_file_write_enable : out std_logic;
        EX_WB_pc_branch_conditional      : out std_logic;
        EX_WB_pc_input_select            : out std_logic_vector(1 downto 0);
        EX_WB_j                          : out std_logic;
        EX_WB_present                    : out std_logic;
        EX_WB_data_memory_address        : out std_logic_vector(15 downto 0);
        EX_WB_data_memory_data_in        : out std_logic_vector(15 downto 0);
        EX_WB_data_memory_data_out       : out std_logic_vector(15 downto 0);
        EX_WB_dprr_clear                 : out std_logic;
        EX_WB_rz_index                   : out std_logic_vector(3 downto 0);
        EX_WB_rz                         : out std_logic_vector(15 downto 0);
        EX_WB_rx                         : out std_logic_vector(15 downto 0);
        EX_WB_immediate                  : out std_logic_vector(15 downto 0);
        EX_WB_pc                         : out std_logic_vector(15 downto 0);
    );
end pipeline_reg_execute;

architecture arch of pipeline_reg_execute is
begin

    process (clock)
    begin
        -- Forward pipeline signals to next stage
        if rising_edge(clock) then
            EX_WB_dpcr_write_enable          <= EX_dpcr_write_enable;
            EX_WB_dpcr_select                <= EX_dpcr_select;
            EX_WB_ssop                       <= EX_ssop;
            EX_WB_jump_select                <= EX_jump_select;
            EX_WB_register_file_write_select <= EX_register_file_write_select;
            EX_WB_data_memory_data_select    <= EX_data_memory_data_select;
            EX_WB_data_memory_address_select <= EX_data_memory_address_select;
            EX_WB_data_memory_write_enable   <= EX_data_memory_write_enable;
            EX_WB_z_register_write_enable    <= EX_z_register_write_enable;
            EX_WB_z_register_reset           <= EX_z_register_reset;
            EX_WB_alu_op_sel                 <= EX_alu_op_sel;
            EX_WB_alu_op1_sel                <= EX_alu_op1_sel;
            EX_WB_alu_op2_sel                <= EX_alu_op2_sel;
            EX_WB_register_file_write_enable <= EX_register_file_write_enable;
            EX_WB_pc_branch_conditional      <= EX_pc_branch_conditional;
            EX_WB_pc_input_select            <= EX_pc_input_select;
            EX_WB_j                          <= EX_j;
            EX_WB_present                    <= EX_present;
            EX_WB_data_memory_address        <= EX_data_memory_address;
            EX_WB_data_memory_data_in        <= EX_data_memory_data_in;
            EX_WB_data_memory_dta_out        <= EX_data_memory_dta_out;
            EX_WB_dprr_clear                 <= EX_dprr_clear;
            EX_WB_rz_index                   <= EX_rz_index;
            EX_WB_rz                         <= EX_rz;
            EX_WB_rx                         <= EX_rx;
            EX_WB_immediate                  <= EX_immediate;
            EX_WB_pc                         <= EX_pc;
        end if;
    end process;

end architecture; -- arch