----------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.aa.all;
----------------------------
entity control_unit is
       port (clock,reset:         in std_logic;
             write:               out std_logic;
             IR:                  in std_logic_vector(7 downto 0);
             IR_load,MAR_load,PC_load,PC_in,A_load,B_load,CCR_load: out std_logic;
             Bus1_sel,Bus2_sel:   out std_logic_vector(1 downto 0);
             CCR_result:          in std_logic_vector(3 downto 0);
             ALU_sel:             out std_logic_vector(2 downto 0));
end entity;
----------------------------
architecture cu_arch of control_unit is

type state_type is  (S_FETCH_0,S_FETCH_1,S_FETCH_2,                                     --OPCODE FETCH STATE

                     S_DECODE_3,                                                        --OPCODE DECODE STATE
                        
                     S_LDA_IMM_4,S_LDA_IMM_5, S_LDA_IMM_6,                              --LOAD A (IMM) STATES

                     S_LDA_DIR_4,S_LDA_DIR_5,S_LDA_DIR_6,S_LDA_DIR_7,S_LDA_DIR_8,       --LOAD A (DIR) STATES
              
                     S_STA_DIR_4,S_STA_DIR_5,S_STA_DIR_6,S_STA_DIR_7,                   --STORE A (DIR) STATES

                     S_LDB_IMM_4,S_LDB_IMM_5,S_LDB_IMM_6,                               --LOAD B (IMM) STATES

                     S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7,                --LOAD B (DIR) STATES

                     S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7,                --STORE B (DIR) STATES

                     S_BRA_4, S_BRA_5, S_BRA_6,                                         --BRANCH STATES
                    
                     S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7,

                     S_BRANCH_4, S_BRANCH_5, S_BRANCH_6, S_BRANCH_7,        

                     S_ADD_AB_4,S_SUB_AB_4,S_AND_AB,S_OR_AB,S_INCA,S_INCB,S_DECA, S_DECB); --ALU INST

signal current_state, next_state: state_type;
 
begin
---------STATE_MEMORY--------
      STATE_MEMORY:process(clock,reset)
                   begin
                     if (reset ='0') then
                       current_state <= S_FETCH_0;
                     elsif (clock'event and clock='1') then
                       current_state <= next_state;
                     end if;
                   end process;
---------NEXT_STATE----------
      NEXT_STATE_LOGIC:process(current_state,IR,CCR_result)
                 begin
                    case current_state is
                     
                      when S_FETCH_0 =>
                           next_state <= S_FETCH_1;
                      when S_FETCH_1 =>
                           next_state <= S_FETCH_2;  --FETCH
                      when S_FETCH_2 =>
                           next_state <= S_DECODE_3;             
                      when S_DECODE_3 =>    

             -- HERE DIFFRENT PATHSIN THEN FSM ARE DECIDED -- 

                           if (IR = LDA_IMM) then         --LOAD A IMM--
                              next_state <= S_LDA_IMM_4;
                           elsif (IR = LDA_DIR) then      --LOAD A DIR--  --REGISTER A--
                              next_state <= S_LDA_DIR_4;
                           elsif (IR = STA_DIR) then      --STORE A DIR--         
                              next_state <= S_STA_DIR_4;        
                           
                           elsif (IR = LDB_IMM) then      --LOAD B IMM--          
                              next_state <= S_LDB_IMM_4;
                           elsif (IR = LDB_DIR) then      --LOAD B DIR--  --REGISTER B--        
                              next_state <= S_LDB_DIR_4;
                           elsif (IR = STB_DIR) then      --STORE B DIR--          
                              next_state <= S_STB_DIR_4;   

                           elsif (IR = BRA) then 
                              next_state <= S_BRA_4;      --BRANCH ALWAYS
                              
                           elsif IR = BCS then
                              if CCR_Result(3) = '1' then
                                 next_state <= S_BRANCH_4;
                              else
                                 next_state <= S_BRANCH_7;
                              end if;
                           elsif (IR=BEQ and CCR_Result(2)='1') then   -- BEQ and Z=1
                              next_state <= S_BEQ_4;
                           elsif (IR=BEQ and CCR_Result(2)='0') then    -- BEQ and Z=0
                              next_state <= S_BEQ_7;
                           elsif IR = BVS then
                              if CCR_Result(1) = '1' then
                                 next_state <= S_BRANCH_4;
                              else
                                 next_state <= S_BRANCH_7;
                              end if;
                           elsif IR = BMI then
                              if CCR_Result(0) = '1' then
                                 next_state <= S_BRANCH_4;
                              else
                                 next_state <= S_BRANCH_7;
                              end if;
                            
                                         
   
                           elsif (IR = ADD_AB) then
                              next_state <= S_ADD_AB_4;
                           elsif (IR = SUB_AB) then
                              next_state <= S_SUB_AB_4;
                           elsif IR = OR_AB then
                              next_state <= S_OR_AB;
                           elsif IR = AND_AB then
                              next_state <= S_AND_AB;
                           elsif IR = INCA then
                              next_state <= S_INCA;
                           elsif IR = DECA then
                              next_state <= S_DECA;
                           elsif IR =INCB then
                              next_state <= S_INCB;
                           elsif IR = DECB then
                              next_state <= S_DECB;

                           END IF;


                     when S_LDA_IMM_4 =>
                          next_state <= S_LDA_IMM_5;
                     when S_LDA_IMM_5 =>                    --
                          next_state <= S_LDA_IMM_6;
                     when S_LDA_IMM_6 =>
                          next_state <= S_FETCH_0; 


                     when S_LDA_DIR_4 =>
                          next_state <= S_LDA_DIR_5;
                     when S_LDA_DIR_5 =>
                          next_state <= S_LDA_DIR_6;
                     when S_LDA_DIR_6 =>
                          next_state <= S_LDA_DIR_7;
                     when S_LDA_DIR_7 =>
                          next_state <= S_FETCH_0;

                    
                     when S_STA_DIR_4 =>
                          next_state <= S_STA_DIR_5;
                     when S_STA_DIR_5 =>
                          next_state <= S_STA_DIR_6;
                     when S_STA_DIR_6 =>
                          next_state <= S_STA_DIR_7;
                     when S_STA_DIR_7 =>
                          next_state <= S_LDA_DIR_8;
                     when S_LDA_DIR_8 =>
                          next_state <= S_FETCH_0;
                     


                     when S_LDB_IMM_4 =>
                          next_state <= S_LDB_IMM_5;
                     when S_LDB_IMM_5 =>
                          next_state <= S_LDB_IMM_6;
                     when S_LDB_IMM_6 =>
                          next_state <= S_FETCH_0;
   

                     when S_LDB_DIR_4 =>
                          next_state <= S_LDB_DIR_5;
                     when S_LDB_DIR_5 =>
                          next_state <= S_LDB_DIR_6;
                     when S_LDB_DIR_6 =>
                          next_state <= S_LDB_DIR_7;
                     when S_LDB_DIR_7 =>
                          next_state <= S_FETCH_0;



                     when S_STB_DIR_4 =>
                          next_state <= S_STB_DIR_5;
                     when S_STB_DIR_5 =>
                          next_state <= S_STB_DIR_6;
                     when S_STB_DIR_6 =>
                          next_state <= S_STB_DIR_7;
                     when S_STB_DIR_7 =>
                          next_state <= S_FETCH_0;



                     when S_ADD_AB_4 =>
                          next_state <= S_FETCH_0;
                     when S_SUB_AB_4 =>
                          next_state <= S_FETCH_0;
                     when S_OR_AB =>
                          next_state <= S_FETCH_0;
                     when S_AND_AB =>
                          next_state <= S_FETCH_0;
                     when S_INCA  =>
                          next_state <= S_FETCH_0;
                     when S_DECA =>
                          next_state <= S_FETCH_0;


                     when S_BRA_4 =>
                          next_state <= S_BRA_5;
                     when S_BRA_5 =>
                          next_state <= S_BRA_6;
                     when S_BRA_6 =>
                          next_state <= S_FETCH_0;



                     when S_BEQ_4 =>
                          next_state <= S_BEQ_5;
                     when S_BEQ_5 =>
                          next_state <= S_BEQ_6;
                     when S_BEQ_6 =>
                          next_state <= S_FETCH_0;
                     when S_BEQ_7 =>
                          next_state <= S_FETCH_0;
                     when others => 
                          next_state <= S_FETCH_0;
                     end case;
                  end process;

       
 
                     
                     
-------------OUTPUT LOGIC----------------
OUTPUT_LOGIC:process(current_state)
             begin
                  case(current_state) is
      when S_FETCH_0 => -- Put PC onto MAR to read Opcode
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_FETCH_1 => -- Increment PC
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_FETCH_2 =>
        IR_Load <= '1';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_DECODE_3 =>
        IR_Load <= '1';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_IMM_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_IMM_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_IMM_6 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_DIR_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_DIR_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_DIR_6 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_DIR_7 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDA_DIR_8 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
 
      when S_STA_DIR_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_STA_DIR_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';        
        ALU_Sel <= "000";
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_STA_DIR_6 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';        
        ALU_Sel <= "000";
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_STA_DIR_7 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';        
        ALU_Sel <= "000";
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '1';
      when S_LDB_IMM_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_IMM_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_IMM_6 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '1';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_DIR_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_DIR_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_DIR_6 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_LDB_DIR_7 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
     
      when S_STB_DIR_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_STB_DIR_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';
        write <= '0';
        ALU_Sel <= "000";
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
      when S_STB_DIR_6 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';
        write <= '0';
        ALU_Sel <= "000";
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
      when S_STB_DIR_7 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        CCR_Load <= '0';
        write <= '1';
        ALU_Sel <= "000";
        Bus1_sel <= "10"; -- "00"=PC, "01"=A, "10"=B
      
      when S_BRA_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRA_5 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRA_6 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '1';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BEQ_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BEQ_5 =>
        -- do nothing;
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BEQ_6 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '1';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BEQ_7 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRANCH_4 =>
        IR_Load <= '0';
        MAR_Load <= '1';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRANCH_5 =>
        -- do nothing:
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRANCH_6 =>
        -- Put from memory into PC
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '1';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_BRANCH_7 =>
        -- Increment PC: don't branch
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '1';
        A_Load <= '0';
        B_Load <= '0';
        ALU_Sel <= "000";
        CCR_Load <= '0';
        Bus1_sel <= "00"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_ADD_AB_4 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_ADD;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_SUB_AB_4 =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_SUB;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_OR_AB =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_OR;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_AND_AB =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_AND;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_INCA =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_INCA;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_INCB =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '1';
        ALU_Sel <= ALU_INCB;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_DECA =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '1';
        B_Load <= '0';
        ALU_Sel <= ALU_DECA;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0';
      when S_DECB =>
        IR_Load <= '0';
        MAR_Load <= '0';
        PC_Load <= '0';
        PC_In <= '0';
        A_Load <= '0';
        B_Load <= '1';
        ALU_Sel <= ALU_DECB;
        CCR_Load <= '1';
        Bus1_sel <= "01"; -- "00"=PC, "01"=A, "10"=B
        Bus2_sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write <= '0'; 
       end case;
   end process;
    
end architecture;
----------------------------
