--  Hello world program
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all; -- Imports the standard textio package.

--  Defines a design entity, without any ports.
entity hello_world is
end hello_world;

architecture behaviour of hello_world is
    
    signal clock : std_logic := '0';
    
begin
    
    clock <= not clock after 5 ns;
    
  process
    variable l : line;
  begin
    write (l, String'("Hello world!"));
    writeline (output, l);
    
    wait for 100 ns;
    wait;
  end process;
end behaviour;