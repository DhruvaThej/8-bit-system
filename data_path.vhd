----------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
----------------------
entity data_path is
port (clock,reset:         in std_logic;
             address,to_memory:   out std_logic_vector(7 downto 0);
             IR_load,MAR_load,PC_load,PC_in,A_load,B_load,CCR_load: in std_logic;
             CCR_result:          out std_logic_vector(3 downto 0);
             from_memory:         in std_logic_vector (7 downto 0);
             Bus1_sel,Bus2_sel:   in std_logic_vector(1 downto 0);
             IR:                  out std_logic_vector (7 downto 0);
             ALU_sel:             in std_logic_vector(2 downto 0));
end entity;
-----------------------
architecture dp_arch of data_path is
--component mux3x1 is
--port (a,b,c: in std_logic_vector(7 downto 0);
--      sel: in std_logic_vector(1 downto 0);
--      y:out std_logic_vector(7 downto 0));
--end component;

component ALU is
port (A,B: in std_logic_vector(7 downto 0);
      ALU_sel:in std_logic_vector (2 downto 0);
      NZVC:out std_logic_vector(3 downto 0);
      result:out std_logic_vector(7 downto 0));
end component;

signal Bus1,Bus2: std_logic_vector (7 downto 0):="00000000";
signal ALU_out: std_logic_vector (7 downto 0):="00000000";
signal NZVC: std_logic_vector (3 downto 0):="0000";
signal A,B,PC,MAR:std_logic_vector (7 downto 0):="00000000";
-- try dir convec using--
signal PC_uns: unsigned(7 downto 0):="00000000";
--signal mux_b1_in: std_logic_vector (7 downto 0);
--signal mux_b2_in: std_logic_vector (7 downto 0);

begin

          --concurrent signal assignments----

to_memory <= Bus1;
address <= MAR;

     AL_UNIT: ALU 
              port map ( A=>A,
                         B=>B,
                         ALU_sel=>ALU_sel,
                         NZVC=>NZVC,
                         result=>ALU_out);
  
  --   MUX_TO_Bus1: mux3x1
  --                port map(a=>PC,
  --                         b=>A,
  --                         c=>B,
  --                         sel=>Bus1_sel,
   --                        y=>mux_b1_in);
   --  MUX_TO_Bus2: mux3x1
   --              port map(a=>ALU_out,
   --                        b=>Bus1,
   --                        c=>from_memory,
   --                        sel=>Bus2_sel,
   --                        y=>mux_b2_in);


           ---multiplexers---
       MUX_Bus1:process(Bus1_sel,PC,A,B)
       begin 
            case(Bus1_sel)is
            when "00"=>Bus1<=PC;
            when "01"=>Bus1<=A;
            when "10"=>Bus1<=B;
            when others=>Bus1<=x"00";
            end case;
       end process;
       
       MUX_Bus2:process(Bus2_sel,ALU_out,Bus1,from_memory)
       begin
          case (Bus1_sel) is
          when "00"=>Bus2<=ALU_out;
          when "01"=>Bus2<=Bus1;
          when "10"=>Bus2<= from_memory;
          when others =>Bus2<=x"00";
          end case;
       end process;
     ---registers----
INSTRUCTION_REGISTER:process(clock,reset)
                     begin
                          if (reset='0') then
                            IR <= x"00";
                          elsif (clock'event and clock='1') then
                            if (IR_load='1') then
                              IR <= Bus2;
                            end if;
                          end if;
                     end process;
MEMORY_ADDRESS_REGISTER:process(clock,reset)
                        begin
                             if (reset='0') then
                               MAR <= x"00";
                             elsif (clock'event and clock='1') then
                                if (MAR_load='1') then 
                                MAR <= Bus2;
                                end if;
                             end if;
                      end process;
PROGRAM_COUNTER:process(clock,reset)
                begin 
                     if (reset='0') then
                       IR <= x"00";
                     elsif (clock'event and clock='1') then
                        if (PC_load ='1') then
                          PC_uns <= unsigned (Bus2);
                        elsif (PC_in='1') then
                          PC_uns <= PC_uns+1;
                        end if;
                     end if;
                end process;
PC <= std_logic_vector (PC_uns);

A_REGISTER:process(clock,reset)
           begin
                if (reset='0') then 
                   A <= x"00";
                elsif rising_edge(clock) then
                   if (A_load='1') then
                     A <= Bus2;
                   end if;
                end if;
           end process;
B_REGISTER:process(clock,reset)
           begin
                if (reset='0') then 
                   B <= x"00";
                elsif rising_edge(clock) then
                   if (B_load='1') then
                     B <= Bus2;
                   end if;
                end if;
           end process;    
CONDITION_CODE_REGISTER:process(clock,reset)
                        begin 
                             if (reset='0') then 
                               CCR_result <= x"0";
                             elsif rising_edge(clock) then
                                 if (CCR_load= '1') then
                                 CCR_result <= NZVC; 
                                 end if;
                             end if;
                        end process;    
  

end architecture;
-----------------------
