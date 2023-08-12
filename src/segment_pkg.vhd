--> package enables simple segment display interfacing

library ieee;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

package segment_pkg is

    --> todo: turn these into generics
    constant DISPLAY_LENGTH : natural range 1 to 8 := 8;

    subtype letter_type is character range ' ' to 'z';

    type encoding_type is array (letter_type) of std_logic_vector(7 downto 0);

    -- todo: maybe we can have a config.txt file depending on our type of seven segment, maybe aided by a Python script?
    constant BCD_ENCODING : encoding_type :=
    (
        '0'    => "00000000",
        '1'    => "00000001",
        'A'    => "00000010",
        ' '    => "11111111",
        others => "00000000"
    );

    type word_type is array(positive range <>) of letter_type;

    --> we need a register that is 8 * DISPLAY_LENGTH bits long
    shared variable encoded_register : std_logic_vector(8 * DISPLAY_LENGTH - 1 downto 0) := (others => '0');

    impure function "=" (l, r : encoding_type) return boolean;

    procedure set_message(message : word_type);

    impure function get_message(message : word_type) return std_logic_vector;

end package;

package body segment_pkg is

    impure function "=" (l, r : encoding_type) return boolean is begin
        return l = r;
    end function;

    --> out_port <= set_message("AA A");
    procedure set_message(message : word_type) is
        variable message_length : natural := message'length;
        variable offset : natural := 0;
    begin
        encoded_register := (others => '0');
        for letter in message_length downto 1 loop
            encoded_register(encoded_register'high - (8 * offset) downto encoded_register'high - (8 * offset) - 7) := BCD_ENCODING(message(letter));
            offset := offset + 1;
        end loop;
    end procedure;

    impure function get_message(message : word_type) return std_logic_vector is
        variable message_length : natural := message'length;
        variable offset : natural := 0;
    begin
        encoded_register := (others => '0');
        for letter in message_length downto 1 loop
            encoded_register(encoded_register'high - (8 * offset) downto encoded_register'high - (8 * offset) - 7) := BCD_ENCODING(message(letter));
            offset := offset + 1;
        end loop;

        return encoded_register;
    end function;

end package body;