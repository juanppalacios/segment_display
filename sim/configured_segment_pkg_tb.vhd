-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

library std;
-- use std.env.all;
use std.textio.all;

library work;

use work.configured_segment_pkg.all;

-- todo: create a simple design and drive DUT

entity segment_pkg_tb is
end entity;

architecture testbench of segment_pkg_tb is

	signal test   : letter_type := 'A';
    constant word : word_type(1 to 3) := "A A";

    signal out_port : std_logic_vector(encoded_register'range) := (others=>'0');

begin

	process begin
        wait for 10 ns;

        assert BCD_ENCODING('1') = "0000001" report "error" severity error;

        wait for 10 ns;

        set_message("AAAAAAAA");
        out_port <= encoded_register;
        report " " & to_bstring(encoded_register);

        --> now we can see that each digit has our value
        set_message("AAAA");
        out_port <= encoded_register;
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message("AAAA AAA");
        out_port <= encoded_register;
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message("AA AA  A");
        out_port <= encoded_register;
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message(word);
        out_port <= encoded_register;
        report " " & to_bstring(encoded_register);

        out_port <= get_message("AA AA");

        wait for 100 ns;

        report " " & to_bstring(out_port);
        wait;
    end process;

end architecture;