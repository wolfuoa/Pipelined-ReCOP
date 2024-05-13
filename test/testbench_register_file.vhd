library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity testbench_register_file is
end entity;

architecture arch of testbench_register_file is

    signal t_clock                 : std_logic;
    signal t_reset                 : std_logic;
    signal t_write_enable          : std_logic;
    signal t_rz_index              : std_logic_vector(3 downto 0);
    signal t_rx_index              : std_logic_vector(3 downto 0);
    signal t_rx                    : std_logic_vector(15 downto 0);
    signal t_rz                    : std_logic_vector(15 downto 0);
    signal t_rz_select             : std_logic;
    signal t_register_write_select : std_logic_vector(2 downto 0);
    signal t_immediate             : std_logic_vector(15 downto 0);
    signal t_data_memory           : std_logic_vector(15 downto 0);
    signal t_alu_out               : std_logic_vector(15 downto 0);
    signal t_sip                   : std_logic_vector(15 downto 0);
    signal t_max                   : std_logic_vector(15 downto 0);
begin

    DUT : entity work.register_file
        port map(
            clock                 => t_clock,
            reset                 => t_reset,
            write_enable          => t_write_enable,
            rz_index              => t_rz_index,
            rx_index              => t_rx_index,
            rx                    => t_rx,
            rz                    => t_rz,
            rz_select             => t_rz_select,
            register_write_select => t_register_write_select,
            immediate             => t_immediate,
            data_memory           => t_data_memory,
            alu_out               => t_alu_out,
            sip                   => t_sip,
            max_result            => t_max
        );

    process
    begin
        t_clock <= '1';
        wait for 10 ns;
        t_clock <= '0';
        wait for 10 ns;
    end process;

    -- Initialise
    process
    begin
        t_reset <= '1';
        wait for 20 ns;
        t_reset <= '0';
        wait;
    end process;

    process
    begin
        t_write_enable <= '0';
        wait for 30 ns;
        t_write_enable <= '1';
        wait for 300 ns;
        t_write_enable <= '0';
        wait for 700 ns;
    end process;

    process
    begin
        t_rz_select             <= '0';
        t_rz_index              <= x"0";
        t_register_write_select <= "000";
        wait for 600 ns;
        t_rz_select             <= '1';
        t_register_write_select <= "001";
        wait for 600 ns;
        t_rz_select             <= '0';
        t_register_write_select <= "010";
        wait for 600 ns;
        t_rz_index              <= x"7";
        t_register_write_select <= "011";
        wait for 600 ns;
    end process;

    process
    begin
        t_alu_out     <= x"A1B2";
        t_data_memory <= x"E5F6";
        t_immediate   <= x"9C8B";
        t_sip         <= x"FEDC";
        wait for 500 ns;
        t_alu_out     <= x"1234";
        t_data_memory <= x"ABCD";
        t_immediate   <= x"2345";
        t_sip         <= x"C0FF";
        wait for 400 ns;
        t_alu_out     <= x"DEAD";
        t_data_memory <= x"FEED";
        t_immediate   <= x"CAFE";
        t_sip         <= x"EEC0";
        wait for 400 ns;
    end process;

end architecture;