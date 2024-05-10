--+----------------------------------------------------------------------------

--|

--| NAMING CONVENSIONS :

--|

--|    xb_<port name>           = off-chip bidirectional port ( _pads file )

--|    xi_<port name>           = off-chip input port         ( _pads file )

--|    xo_<port name>           = off-chip output port        ( _pads file )

--|    b_<port name>            = on-chip bidirectional port

--|    i_<port name>            = on-chip input port

--|    o_<port name>            = on-chip output port

--|    c_<signal name>          = combinatorial signal

--|    f_<signal name>          = synchronous signal

--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)

--|    <signal name>_n          = active low signal

--|    w_<signal name>          = top level wiring signal

--|    g_<generic name>         = generic

--|    k_<constant name>        = constant

--|    v_<variable name>        = variable

--|    sm_<state machine type>  = state machine type definition

--|    s_<signal name>          = state name

--|

--+----------------------------------------------------------------------------

library ieee;

  use ieee.std_logic_1164.all;

  use ieee.numeric_std.all;
 
 
entity top_basys3 is

-- TODO

    port(

        clk     :   in std_logic; -- native 100MHz FPGA clock

        sw      :   in std_logic_vector(7 downto 0);

        btnU    :   in std_logic; -- master_reset

        btnC    :   in std_logic; -- fsm_reset

        -- outputs

        led :   out std_logic_vector(15 downto 0);

        -- 7-segment display segments (active-low cathodes)

        seg :   out std_logic_vector(6 downto 0);

        -- 7-segment display active-low enables (anodes)

        an  :   out std_logic_vector(3 downto 0)       

    );

end top_basys3;
 
--entity mux_3to1 is

--    port(

--        num1 : in std_logic_vector(2 downto 0);

--        num2 : in std_logic_vector(2 downto 0);

--        answer : in std_logic_vector(2 downto 0);

--        sel : in std_logic_vector(1 downto 0);

--        selNumber : out std_logic_vector(2 downto 0)

--    );

--end mux_3to1;
 
architecture top_basys3_arch of top_basys3 is 

	-- declare components and signals

    component regA is

        port( i_cycle  : in STD_LOGIC_VECTOR (3 downto 0); 

              i_regA : in STD_LOGIC_VECTOR (7 downto 0);

              o_regA : out STD_LOGIC_VECTOR (7 downto 0));

    end component regA;

    component regB is

        port( i_cycle  : in STD_LOGIC_VECTOR (3 downto 0); 

              i_regB : in STD_LOGIC_VECTOR (7 downto 0);

              o_regB : out STD_LOGIC_VECTOR (7 downto 0));

    end component regB;

	component controller_fsm is

        port ( 

               i_reset      : in  STD_LOGIC; -- synchronous

               i_adv        : in  STD_LOGIC;
               
               i_clk        : in STD_LOGIC;

               o_cycle      : out STD_LOGIC_VECTOR (3 downto 0));

    end component controller_fsm;


	component twoscomp_decimal is

        port ( 

               i_bin    : in STD_LOGIC_VECTOR (7 downto 0);

               o_sign      : out STD_LOGIC_VECTOR (3 downto 0);

               o_hund      : out STD_LOGIC_VECTOR (3 downto 0);

               o_tens      : out STD_LOGIC_VECTOR (3 downto 0);

               o_ones      : out STD_LOGIC_VECTOR (3 downto 0));

    end component twoscomp_decimal;

	component TDM4 is

        port ( i_clk  : in std_logic; 

               i_sign      : in STD_LOGIC_VECTOR (3 downto 0);

               i_hund      : in STD_LOGIC_VECTOR (3 downto 0);

               i_tens      : in STD_LOGIC_VECTOR (3 downto 0);

               i_ones      : in STD_LOGIC_VECTOR (3 downto 0);

               o_sel   : out STD_LOGIC_VECTOR (3 downto 0);

               o_data : out STD_LOGIC_VECTOR (3 downto 0)

               );

    end component TDM4;


    component sevenSegDecoder is

      port(

         i_D : in std_logic_vector (3 downto 0);

         o_S : out std_logic_vector (6 downto 0)

      );    

    end component sevenSegDecoder;    

    component ALU is

      port(

         i_A : in std_logic_vector (7 downto 0);

         i_B : in std_logic_vector (7 downto 0);

         i_op : in std_logic_vector (2 downto 0);
         
         i_cycle : in std_logic_vector (3 downto 0);
         
         o_result : out std_logic_vector (7 downto 0);

         o_flags : out std_logic_vector (2 downto 0)

      );    

    end component ALU;  

    --CLOCK

    component clock_divider is      

            generic ( constant k_DIV : natural := 2 );

            port (  i_clk    : in std_logic;           -- basys3 clk

                    o_clk    : out std_logic           -- divided (slow) clock

            );          

    end component clock_divider;    

    --MUX_3to1  -------------------------------------------------------------

--    component mux_3to1 is

--            port(

--                i_num1 : in std_logic_vector (7 downto 0);

--                i_answer : in std_logic_vector (7 downto 0);

--                i_num2 : in std_logic_vector (7 downto 0);

--                i_sel  : in std_logic_vector (3 downto 0);

--                o_selNumber : in std_logic_vector (7 downto 0)

--            );

--    end component mux_3to1;
    
    --MUX_2to1  -------------------------------------------------------------

--    component mux_2to1 is

--            port(

--                i_cycle : in std_logic_vector (3 downto 0);

--                i_sel : in std_logic_vector (3 downto 0);

--                i_off : in std_logic_vector (3 downto 0);

--                o_an : in std_logic_vector (3 downto 0)

--            );

--    end component mux_2to1;

    -- SIGNALS ---------------------------------------------------------   

	signal w_clk1, w_clk2 : std_logic;		

    signal w_sign, w_hund, w_tens, w_ones : std_logic_vector (3 downto 0);

    signal w_regA, w_regB, w_alu, w_display: std_logic_vector (7 downto 0); 

    signal w_cycle, w_seg, w_sel, w_dataTDM : std_logic_vector (3 downto 0);
    
    

begin

	-- PORT MAPS --------------------------------------------------------
	
    clkdiv_inst1 : clock_divider         --instantiation of clock_divider to take 

           generic map ( k_DIV => 12500000 )

           port map (                          

               i_clk   => clk,

               o_clk    => w_clk1

           );     
           
    clkdiv_inst2 : clock_divider         --instantiation of clock_divider to take 
       
              generic map ( k_DIV => 208000 )
  
              port map (                          
   
                  i_clk   => clk,
   
                  o_clk    => w_clk2
   
              );    

    controller_fsm_isnt: controller_fsm

            port map(
    
                i_reset => btnU,
    
                i_adv => btnC,
    
                o_cycle => w_cycle,
                
                i_clk => w_clk1
    
            );

	sevenSegDecoder_inst: sevenSegDecoder

           port map(

               i_D => w_dataTDM,

               o_S => seg

           ); 

	TDM4_inst: TDM4

          port map(

              i_clk => w_clk2,

              i_sign => w_sign,

              i_hund => w_hund,

              i_tens => w_tens,

              i_ones => w_ones,

              o_sel => w_sel,

              o_data => w_dataTDM

          );
 
	ALU_inst: ALU

          port map(

              i_A => w_regA,

              i_B => w_regB,

              i_op => sw(2 downto 0),
              
              i_cycle => w_cycle,

              o_result => w_alu,
              
              o_flags(0) => led(13),    -- flags sent to led's here

              o_flags(1) => led(14),
              
              o_flags(2) => led(15)
          );

	twoscomp_decimal_inst: twoscomp_decimal

          port map( 

               i_bin => w_display,

               o_sign => w_sign,

               o_hund => w_hund,

               o_tens => w_tens,

               o_ones => w_ones

          );

    regA_inst: regA

            port map(

              i_cycle => w_cycle,

              i_regA => sw(7 downto 0),

              o_regA => w_regA

            );

    regB_inst: regB

            port map(

              i_cycle => w_cycle,

              i_regB => sw(7 downto 0),

              o_regB => w_regB

            );

--    mux_3to1_inst:  mux_3to1          ----------mux?

--        port map(
        
--            i_num1 => w_regA,
            
--            i_answer => w_alu,
            
--            i_num2  =>  w_regB,
            
--            i_sel    =>  w_cycle,
            
--            o_selNumber =>  w_display
            
--        );
        
--    mux_2to1_inst: mux_2to1
       
--       port map(

--                i_cycle => w_cycle,

--                i_sel => w_sel,

--                i_off => "1111",
                
--                -- what is wrong here?

--                o_an => an(3 downto 0)

--       );

	-- CONCURRENT STATEMENTS ----------------------------

	led(0) <= '1' when w_cycle = "0001" else
	          '0';
    led(1) <= '1' when w_cycle = "0010" else
              '0';
    led(2) <= '1' when w_cycle = "0100" else
              '0';
    led(3) <= '1' when w_cycle = "1000" else
              '0';

	led(12 downto 4) <= (others => '0');
	
    an(3 downto 0) <= "1111" when w_cycle = "0001" else 
                    w_sel;
            
    w_display <= w_regA when w_cycle = "0010" else 
                 w_regB when w_cycle = "0100" else
                 w_alu  when w_cycle = "1000" else
                 "00000000";

end top_basys3_arch;
