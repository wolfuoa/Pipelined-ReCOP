library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity max is
    port (
        op1    : in  std_logic_vector(15 downto 0);
        op2    : in  std_logic_vector(15 downto 0);

        result : out std_logic_vector(15 downto 0) := X"0000"
    );
end entity;

architecture bhv of max is
begin

    result <= op1 when (op1 > op2) else
              op2;

end architecture; -- max