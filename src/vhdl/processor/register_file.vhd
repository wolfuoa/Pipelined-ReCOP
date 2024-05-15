library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.mux_select_constants;

entity register_file is
    port (
        clock                 : in  std_logic;
        reset                 : in  std_logic;

        -- control signal to allow data to write into Rz
        write_enable          : in  std_logic;

        -- Rz and Rx select signals, i.e to select r12
        rz_index              : in  std_logic_vector(3 downto 0) := x"0";
        rx_index              : in  std_logic_vector(3 downto 0) := x"0";

        -- select rz from IR or r7
        rz_select             : in  std_logic;

        -- select signal for input data to be written into Rz
        register_write_select : in  std_logic_vector(2 downto 0);

        -- input data
        immediate             : in  std_logic_vector(15 downto 0);
        data_memory           : in  std_logic_vector(15 downto 0);
        alu_out               : in  std_logic_vector(15 downto 0);
        sip                   : in  std_logic_vector(15 downto 0);
        max_result            : in  std_logic_vector(15 downto 0);

        -- register data outputs
        rx                    : out std_logic_vector(15 downto 0);
        rz                    : out std_logic_vector(15 downto 0)
    );
end entity;

architecture beh of register_file is
    type reg_array is array (15 downto 0) of std_logic_vector(15 downto 0);
    signal regs          : reg_array := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
    signal temp_rz_index : std_logic_vector(3 downto 0);
    signal data_input_z  : std_logic_vector(15 downto 0);
begin

    -- mux selecting address for Rz
    with rz_select select temp_rz_index <=
                                          x"7" when '1',
                                          rz_index when others;

    -- mux selecting input data to be written to Rz
    with register_write_select select data_input_z
        <=
        immediate when mux_select_constants.regfile_write_immediate,
        alu_out when mux_select_constants.regfile_write_aluout,
        data_memory when mux_select_constants.regfile_write_data_memory_register,
        sip when mux_select_constants.regfile_write_sip,
        max_result when mux_select_constants.regfile_write_max,
        x"0000" when others;

    process (clock, reset)
    begin
        if reset = '1' then
            regs <= ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'));
            -- Write on the falling edge to prevent pipeline register from altering result
        elsif falling_edge(clock) then
            -- write data into Rz if ld signal is asserted
            if write_enable = '1' then
                regs(to_integer(unsigned(temp_rz_index))) <= data_input_z;
            end if;
        end if;
    end process;

    rx <= regs(to_integer(unsigned(rx_index)));
    rz <= regs(to_integer(unsigned(temp_rz_index)));

end architecture;