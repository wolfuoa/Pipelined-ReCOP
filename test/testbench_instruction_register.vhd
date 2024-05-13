library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity testbench_instruction_register is
end testbench_instruction_register;

architecture arch of testbench_instruction_register is
    signal t_clock : std_logic;
    signal t_reset : std_logic;
    signal t_write_enable : std_logic;
    signal t_instruction : std_logic_vector(31 downto 0);
    signal t_addressing_mode : std_logic_vector(1 downto 0);
    signal t_opcode : std_logic_vector(5 downto 0);
    signal t_rz : std_logic_vector(3 downto 0);
    signal t_rx : std_logic_vector(3 downto 0);
    signal t_immediate : std_logic_vector(15 downto 0);
begin
    DUT : entity work.instruction_register
        port map(
            clock => t_clock,
            reset => t_reset,
            write_enable => t_write_enable,
            instruction => t_instruction,
            addressing_mode => t_addressing_mode,
            opcode => t_opcode,
            rz => t_rz,
            rx => t_rx,
            immediate => t_immediate
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
        wait;
    end process;
    process
    begin
        t_instruction <= x"BEEFC0CC";
        wait for 500 ns;
        t_instruction <= x"C0CCBEEF";
        wait for 400 ns;
        t_instruction <= x"10016969";
        wait for 400 ns;
    end process;

end arch;