--> package enables simple segment display interfacing

library ieee;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

package generic_segment_pkg is
    generic (
        DISPLAY_CONFIGURATION : string;
        VERBOSE        : boolean;
        SEGMENT_COUNT  : natural range 7 to 8;
        DISPLAY_LENGTH : natural range 1 to 8
    );

    subtype letter_type is character range ' ' to 'z';

    type encoding_type is array (letter_type) of std_logic_vector(SEGMENT_COUNT - 1 downto 0);

    type word_type is array(positive range <>) of letter_type;

    type sentence_type is array(positive range <>) of word_type;

    constant ENCODING_BITWIDTH : std_logic_vector((DISPLAY_LENGTH * SEGMENT_COUNT) - 1 downto 0) := (others => '0');

    --> --- METHODS --- <--

    impure function "=" (l, r : encoding_type) return boolean;

    impure function configure_display return encoding_type;

    impure function set_message(message : word_type) return std_logic_vector;

    impure function to_string(arg : word_type) return string;

end package;

package body generic_segment_pkg is

    impure function "=" (l, r : encoding_type) return boolean is begin
        return l = r;
    end function;

    impure function configure_display return encoding_type is
        variable encoding_config : encoding_type;
    begin
        assert not VERBOSE report "configuring display with " & DISPLAY_CONFIGURATION &
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

    impure function set_message(message : word_type) return std_logic_vector is
        constant BCD_ENCODING : encoding_type := configure_display;
        variable encoded_register : std_logic_vector((DISPLAY_LENGTH * SEGMENT_COUNT) - 1 downto 0) := (others => '0');
        variable message_length   : natural := message'length;
        variable offset      : natural := 0;
        variable left_bound  : natural := 0;
        variable right_bound : natural := 0;
    begin
        assert message_length <= DISPLAY_LENGTH report "message length MUST be less than " & integer'image(DISPLAY_LENGTH) severity error;
        encoded_register := (others => '0');

        for letter in 1 to message_length loop
            -- --> define our character's bit-boundaries
            left_bound  := encoded_register'high - (SEGMENT_COUNT * offset);
            right_bound := left_bound - SEGMENT_COUNT + 1;

            --> add current character to our register
            encoded_register(left_bound downto right_bound) := BCD_ENCODING(message(letter));
            offset := offset + 1;
        end loop;

        return encoded_register;
    end function;

    impure function to_string(arg : word_type) return string is
        variable new_string : string(1 to arg'length);
    begin
        for letter in arg'range loop
            new_string(letter) := arg(letter);
        end loop;
        return new_string;
    end function;

end package body;

library work;
package configured_segment_pkg is new work.generic_segment_pkg
    generic map (
        DISPLAY_CONFIGURATION => "common cathode",
        -- DISPLAY_CONFIGURATION => "common anode",
        VERBOSE               => false,
        SEGMENT_COUNT         => 7,
        DISPLAY_LENGTH        => 8
    );