-----------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------
entity CPU is
port (clock:        in std_logic;
      reset:        in std_logic;
      address:      out std_logic_vector(7 downto 0);
      write:        out std_logic;
      from_memory:  in std_logic_vector (7 downto 0);
      to_memory:    out std_logic_vector (7 downto 0));
end entity;
-----------------------
architecture CPU_architecture of CPU is
    
   component data_path is
       port (clock,reset:         in std_logic;
             address,to_memory:   out std_logic_vector(7 downto 0);
             IR_load,MAR_load,PC_load,PC_in,A_load,B_load,CCR_load: in std_logic;
             CCR_result:          out std_logic_vector(3 downto 0);
             from_memory:         in std_logic_vector (7 downto 0);
             Bus1_sel,Bus2_sel:   in std_logic_vector(1 downto 0);
             IR:                  out std_logic_vector(7 downto 0);
             ALU_sel:             in std_logic_vector(2 downto 0));
   end component;

   component control_unit is
       port (clock,reset:         in std_logic;
             write:               out std_logic;
             IR:                  in std_logic_vector (7 downto 0);
             IR_load,MAR_load,PC_load,PC_in,A_load,B_load,CCR_load: out std_logic;
             Bus1_sel,Bus2_sel:   out std_logic_vector(1 downto 0);
             CCR_result:          in std_logic_vector(3 downto 0);
             ALU_sel:             out std_logic_vector(2 downto 0));
   end component;
   
   signal IR_load,MAR_load,PC_load,PC_in,A_load,B_load,CCR_load: std_logic;
   signal IR:                std_logic_vector(7 downto 0);
   signal ALU_sel:           std_logic_vector(2 downto 0);
   signal CCR_result:       std_logic_vector(3 downto 0);
   signal Bus1_sel,Bus2_sel: std_logic_vector(1 downto 0);

begin 
     M_CONTROL_UNIT: control_unit
                   port map (clock      => clock,
                             reset      => reset,        
                             write      => write,              
                             IR         => IR,               
                             IR_load    => IR_load,
                             MAR_load   => MAR_load,
                             PC_load    => PC_load,
                             PC_in      => PC_in,
                             A_load     => A_load,
                             B_load     => B_load,
                             CCR_load   => CCR_load,
                             Bus1_sel   => Bus1_sel,
                             Bus2_sel   => Bus2_sel, 
                             CCR_result => CCR_result,        
                             ALU_sel    => ALU_sel);
      M_DATA_PATH: data_path
                   port map  (clock       => clock,
                              reset       => reset,  
                              address     => address,
                              to_memory   => to_memory,  
                              IR_load     => IR_load,
                              MAR_load    => MAR_load,
                              PC_load     => PC_load,
                              PC_in       => PC_in,
                              A_load      => A_load,
                              B_load      => B_load,
                              CCR_load    => CCR_load,
                              CCR_result  => CCR_result,         
                              from_memory => from_memory,         
                              Bus1_sel    => Bus1_sel,
                              Bus2_sel    => Bus2_sel,
                              IR          => IR,                 
                              ALU_sel     => ALU_sel);
                     
     
end architecture;
-----------------------
