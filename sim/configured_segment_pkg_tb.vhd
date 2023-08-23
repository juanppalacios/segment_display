-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

library std;
use std.env.all;
use std.textio.all;

library work;

use work.configured_segment_pkg.all;

-- todo: create a simple design and drive DUT

entity segment_pkg_tb is
end entity;

architecture testbench of segment_pkg_tb is

    constant test_data : sentence_type(1 to 8) := (
        "AA  11  ",
        "AAAA    ",
        "AA  A   ",
        "A   AA  ",
        "A   1   ",
        "A   1111",
        "1111A   ",
        "11111111"
    );

    signal message : std_logic_vector(ENCODING_BITWIDTH'range) := (others=>'0');

begin

	process begin
        wait for 10 ns;

        for i in test_data'range loop
            message <= set_message(test_data(i));
            wait for 10 ns;
        end loop;

        finish;
    end process;

end architecture;