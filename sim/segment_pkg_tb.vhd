-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

library std;
-- use std.env.all;
use std.textio.all;

library work;

use work.segment_pkg.all;

entity a is
end entity;

architecture tb of a is

	signal test   : letter_type := 'A';
    signal word : word_type(1 to 3) := "A A";

    signal out_port : std_logic_vector(encoded_register'range) := (others=>'0');

begin

	process begin
        wait for 10 ns;

        assert BCD_ENCODING('1') = "00000001" report "error" severity error;

        wait for 10 ns;

        set_message("AA");
        report " " & to_bstring(encoded_register);

        --> now we can see that each digit has our value
        set_message("AAAA");
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message("AAAA AAA");
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message("AA AA  A");
        report " " & to_bstring(encoded_register);

        wait for 10 ns;

        set_message(word);
        report " " & to_bstring(encoded_register);

        out_port <= get_message("AA AA");

        wait for 10 ns;

        report "our port: " & to_bstring(out_port);



        wait;
    end process;
end;