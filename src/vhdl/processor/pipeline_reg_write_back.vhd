entity pipeline_reg_write_back is
    port (
        clock                             : in  std_logic;
        enable                            : in  std_logic;
        reset                             : in  std_logic;

        WB_register_file_write_enable     : in  std_logic;
        WB_register_file_write_select     : in  std_logic_vector(2 downto 0);
        WB_rz_index                       : in  std_logic_vector(3 downto 0);
        WB_alu_result                     : in  std_logic_vector(15 downto 0);
        WB_data_memory_data_out           : in  std_logic_vector(15 downto 0);
        WB_immediate                      : in  std_logic_vector(15 downto 0);
        WB_max                            : in  std_logic_vector(15 downto 0);
        WB_sip_data_out                   : in  std_logic_vector(15 downto 0);

        WB_END_register_file_write_enable : out std_logic;
        WB_END_register_file_write_select : out std_logic_vector(2 downto 0);
        WB_END_rz_index                   : out std_logic_vector(3 downto 0);
        WB_END_alu_result                 : out std_logic_vector(15 downto 0);
        WB_END_data_memory_data_out       : out std_logic_vector(15 downto 0);
        WB_END_immediate                  : out std_logic_vector(15 downto 0);
        WB_END_max                        : out std_logic_vector(15 downto 0);
        WB_END_sip_data_out               : out std_logic_vector(15 downto 0);
    );
end pipeline_reg_write_back;

architecture arch of pipeline_reg_write_back is

begin

    process (clock)
        -- Propagate signals from EX to WB stage
        if rising_edge(clock) then
            WB_END_register_file_write_enable <= WB_register_file_write_enable;
            WB_END_register_file_write_select <= WB_register_file_write_select;
            WB_END_rz_index                   <= WB_rz_index;
            WB_END_alu_result                 <= WB_alu_result;
            WB_END_data_memory_data_out       <= WB_data_memory_data_out;
            WB_END_immediate                  <= WB_immediate;
            WB_END_max                        <= WB_max;
            WB_END_sip_data_out               <= WB_sip_data_out;
        end if;
    end process;

end architecture; -- arch