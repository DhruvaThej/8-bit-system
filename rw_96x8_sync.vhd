
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

use WORK.aa.all;

entity data_memory_96x8_sync is
  port(address  : in std_logic_vector(7 downto 0);
       data_in  : in std_logic_vector(7 downto 0);
       write    : in std_logic;
       clock    : in std_logic;
       
       data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rw_96x8_sync_arch of data_memory_96x8_sync is

  type RW_type is array(128 to 223) of std_logic_vector(7 downto 0);
  signal rw : RW_type;
  signal EN: std_logic:='0';

begin
  ENABLE: process (address)
          begin
               if (to_integer(unsigned(address)) >= 128) and 
                  (to_integer(unsigned(address)) <= 223) then
                  EN <= '1';
               else 
                  EN <= '0';
               end if;
          end process;

  MEMORY : process(clock)
           begin
                if rising_edge(clock) then
                  if (write = '1' and EN = '1') then
                  rw(to_integer(unsigned(address))) <= data_in;
                  elsif (EN='1' and write='0') then
                  data_out <= rw(to_integer(unsigned(address)));
                  end if;

                  --else     
                  --for I in 0 to rw'length -1 loop
                  --rw(i) <= x"00";
                  --end loop;
                  --end if;
                end if;
  end process;


end architecture;

