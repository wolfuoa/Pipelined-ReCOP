entity decode is
    port (
        clock           : in  std_logic;
        enable          : in  std_logic;
        reset           : in  std_logic;

        instruction     : in  std_logic_vector(31 downto 0);

        addressing_mode : out std_logic_vector(1 downto 0);
        opcode          : out std_logic_vector(5 downto 0);
        rz              : out std_logic_vector(3 downto 0);
        rx              : out std_logic_vector(3 downto 0);
        immediate       : out std_logic_vector(15 downto 0)
    );
end decode;

architecture arch of decode is

begin

    addressing_mode <= instruction(31 downto 30);
    opcode          <= instruction(29 downto 24);
    rz              <= instruction(23 downto 20);
    rx              <= instruction(19 downto 16);
    immediate       <= instruction(15 downto 0);

end architecture; -- arch