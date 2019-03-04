-------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije
--  Autor: LPRS2  <lprs2@rt-rk.com>                                           
--                                                                             
--  Ime modula: timer_counter                                                           
--                                                                             
--  Opis:                                                               
--                                                                             
--    Modul broji sekunde i prikazuje na LED diodama                                         
--                                                                             
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY timer_counter IS PORT (
                              clk_i         : IN STD_LOGIC;                    -- ulazni takt
                              rst_i         : IN STD_LOGIC;                    -- reset aktivan 
                              one_sec_i     : IN STD_LOGIC;                    -- signal koji predstavlja proteklu jednu sekundu vremena 
                              cnt_en_i      : IN STD_LOGIC;                    -- signal dozvole brojanja
                              cnt_rst_i     : IN STD_LOGIC;                    -- signal resetovanja brojaca (clear signal)

                              -- modul se prosiruje sa dva ulaza koji predstavljaju stanja tastera

                              button_min_i  : IN STD_LOGIC;                    -- taster koji cijim se aktiviranjem na LE diodama prikazuju protekle minute
                              button_hour_i : IN STD_LOGIC;                    -- taster koji cijim se aktiviranjem na LE diodama prikazuju protekli sati
                              led_o         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- izlaz ka LE diodama
                             );
END timer_counter;

ARCHITECTURE rtl OF timer_counter IS
	
	component reg is
		generic(
			WIDTH    : positive := 1;
			RST_INIT : integer := 0
		);
		port(
			i_clk  : in  std_logic;
			in_rst : in  std_logic;
			i_d    : in  std_logic_vector(WIDTH-1 downto 0);
			o_q    : out std_logic_vector(WIDTH-1 downto 0)
		);
	end component;
	
SIGNAL counter_value_s   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal next_counter_value_s : std_logic_vector(7 downto 0);

SIGNAL counter_for_min_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL next_counter_for_min_s : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL counter_for_h_s   : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL next_counter_for_h_s   : STD_LOGIC_VECTOR(7 DOWNTO 0);

signal s_cmp : std_logic;
signal min_cmp : std_logic;
constant min_const : std_logic_vector(7 downto 0) := "00111100";

begin

-- DODATI :

-- sistem za brojane sekundi,minuta i sata kao sistem za generisanje izlaza u odnosu na pritisnuti taster
-- ako nije pritisnut nijedan taster onda se prikazuju sekunde
	reg_counter : reg
		generic map(
			WIDTH => 8,
			RST_INIT => 0
		)
		port map(
			i_clk => clk_i,
			in_rst => not rst_i,
			i_d => next_counter_value_s,
			o_q => counter_value_s
		);
	
	reg_min_counter : reg
		generic map(
			WIDTH => 8,
			RST_INIT => 0
		)
		port map(
			i_clk => clk_i,
			in_rst => not rst_i,
			i_d => next_counter_for_min_s,
			o_q => counter_for_min_s
		);
	
	reg_hour_counter : reg
		generic map(
			WIDTH => 8,
			RST_INIT => 0
		)
		port map(
			i_clk => clk_i,
			in_rst => not rst_i,
			i_d => next_counter_for_h_s,
			o_q => counter_for_h_s
		);
		
	s_cmp <= '1' when counter_value_s = min_const else
				'0';
	
	next_counter_value_s <= conv_std_logic_vector(0, 8) when cnt_rst_i = '1' or s_cmp= '1' else
									counter_value_s + one_sec_i when cnt_en_i = '1' else
									counter_value_s;
									
	
	min_cmp<= '1' when counter_for_min_s = min_const else
				'0';
				
				
	next_counter_for_min_s <= 	conv_std_logic_vector(0,8) when min_cmp='1' else
										counter_for_min_s + 1 when s_cmp='1'   else
									   counter_for_min_s;
										
										
	
	next_counter_for_h_s <= counter_for_h_s + 1 when min_cmp='1' else
									counter_for_h_s;
									
									  
	led_o(7 downto 6) <= counter_for_h_s(1 downto 0) when button_hour_i = '0' else
								"00";
								
	led_o(5 downto 0) <= counter_for_min_s(5 downto 0) when button_min_i = '0' else
								"000000";
	
END rtl;