--> package enables simple segment display interfacing

-- todo: find a way to configure bits

library ieee;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

package generic_segment_pkg is
    generic (
        DISPLAY_CONFIGURATION : string;
        SEGMENT_COUNT  : natural range 7 to 8;
        DISPLAY_LENGTH : natural range 1 to 8
    );

    subtype letter_type is character range ' ' to 'z';

    type encoding_type is array (letter_type) of std_logic_vector(SEGMENT_COUNT - 1 downto 0);

    type word_type is array(positive range <>) of letter_type;

    --> we need a register that is 8 * DISPLAY_LENGTH bits long
    shared variable encoded_register : std_logic_vector((DISPLAY_LENGTH * SEGMENT_COUNT) - 1 downto 0) := (others => '0');

    --> --- METHODS --- <--

    impure function "=" (l, r : encoding_type) return boolean;

    impure function configure_display return encoding_type;

    procedure set_message(message : word_type);

    impure function get_message(message : word_type) return std_logic_vector;

    constant BCD_ENCODING : encoding_type := configure_display;

end package;

package body generic_segment_pkg is

    impure function "=" (l, r : encoding_type) return boolean is begin
        return l = r;
    end function;

    impure function configure_display return encoding_type is
        variable encoding_config : encoding_type;
    begin
        report "configuring display with " & DISPLAY_CONFIGURATION &
            ", segment count: "   & integer'image(SEGMENT_COUNT) &
            ", display length: " & integer'image(DISPLAY_LENGTH) severity note;

        if DISPLAY_CONFIGURATION = "common cathode" then
            if SEGMENT_COUNT = 7 then
                encoding_config :=
                (
                    '0'    => "1000000",
                    '1'    => "0000001",
                    'A'    => "0001010",
                    ' '    => "0000000",
                    others => (others => '0')
                );
            else
                encoding_config :=
                (
                    '0'    => "10000000",
                    '1'    => "00000010",
                    'A'    => "00010100",
                    ' '    => "00000000",
                    others => (others => '0')
                );
            end if;

            return encoding_config;
        elsif DISPLAY_CONFIGURATION = "common anode" then
            if SEGMENT_COUNT = 7 then
                encoding_config :=
                (
                    '0'    => "1000000",
                    '1'    => "0000001",
                    'A'    => "0001010",
                    ' '    => "0000000",
                    others => (others => '0')
                );
            else
                encoding_config :=
                (
                    '0'    => "10000000",
                    '1'    => "00000010",
                    'A'    => "00010100",
                    ' '    => "00000000",
                    others => (others => '0')
                );
            end if;
            return encoding_config;
        else
            report "INVALID DISPLAY CONFIGURATION" severity error;
        end if;
    end function;

    procedure set_message(message : word_type) is
        variable message_length : natural := message'length;
        variable offset : natural := 0;
        variable left_bound  : natural := 0;
        variable right_bound : natural := 0;
    begin
        assert message_length <= DISPLAY_LENGTH report "message length MUST be less than " & integer'image(DISPLAY_LENGTH) severity error;
        encoded_register := (others => '0');
        report integer'image(encoded_register'length) severity note;
        for letter in message_length downto 1 loop
            
            --> define our character's bit-boundaries
            left_bound := ;
            
            report "for-loop: "
                & integer'image((encoded_register'high - (SEGMENT_COUNT * offset)) - (encoded_register'high - (SEGMENT_COUNT * offset) - SEGMENT_COUNT))
                & ":";
                -- & integer'image(encoded_register'high - (SEGMENT_COUNT * offset) - SEGMENT_COUNT);

            report "current letter: " & to_string(letter) & ", " & to_string(BCD_ENCODING(message(letter))) severity note;

            --> from our left to right bit-bound, append our letter's segment
            encoded_register(encoded_register'high - offset downto encoded_register'high - SEGMENT_COUNT + 1) := (others => '1');
            -- encoded_register(encoded_register'high - (SEGMENT_COUNT * offset) downto (encoded_register'high - (SEGMENT_COUNT * offset) - SEGMENT_COUNT)) := BCD_ENCODING(message(letter));
            offset := (offset * SEGMENT_COUNT) + 1;
            report "passed loop: " & integer'image(letter) severity note;
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

library work;
package configured_segment_pkg is new work.generic_segment_pkg
    generic map (
        -- DISPLAY_CONFIGURATION => "common cathode",
        DISPLAY_CONFIGURATION => "common anode",
        SEGMENT_COUNT         => 7,
        DISPLAY_LENGTH        => 8
    );