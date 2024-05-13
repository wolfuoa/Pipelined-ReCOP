LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY second_cycle IS
    PORT MAP(
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        enable : IN  STD_LOGIC;
        q      : OUT STD_LOGIC;
    );
END ENTITY second_cycle;

ARCHITECTURE arch OF second_cycle IS

    SIGNAL output : STD_LOGIC;

BEGIN

    PROCESS
        VARIABLE current_cycle : INTEGER
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (reset = "1") THEN
                output <= "0";
            END IF;
            IF (enable = "1") THEN
                output <= NOT output;
            END IF;
        END IF;
    END PROCESS;

    q <= output;

END arch; -- arch